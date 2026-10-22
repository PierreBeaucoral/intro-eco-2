# cm2.R · graphiques du CM 2 (prix du tabac : élasticité, incidence, addiction),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm2.qmd sont définies ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.

#' Variation en pourcentage de x0 à x1
var_pct <- function(x0, x1) 100 * (x1 - x0) / x0

#' Équilibre d'une demande Q = a - b P et d'une offre Q = c + s (P - t),
#' où t est une taxe unitaire versée par le vendeur (le vendeur garde P - t).
#' @return liste (p = prix payé par l'acheteur, pv = prix gardé par le vendeur, q)
equilibre_taxe <- function(a, b, c, s, t = 0) {
  p <- (a - c + s * t) / (b + s)
  list(p = p, pv = p - t, q = a - b * p)
}

# ---------------------------------------------------------------------------
# 1. Exemple 1 de la page : élasticité et dépense des fumeurs (marché fictif)
#    Le paquet passe de 10 € à 12 € ; 100 millions de paquets vendus au départ.
# ---------------------------------------------------------------------------
ex1_cm2 <- list(p0 = 10, p1 = 12, q0 = 100, e_faible = -0.4, e_forte = -1.5)
ex1_cm2$q1_faible <- ex1_cm2$q0 * (1 + ex1_cm2$e_faible * var_pct(ex1_cm2$p0, ex1_cm2$p1) / 100)
ex1_cm2$q1_forte  <- ex1_cm2$q0 * (1 + ex1_cm2$e_forte  * var_pct(ex1_cm2$p0, ex1_cm2$p1) / 100)

#' Couleur unie équivalente à `couleur` posée avec la transparence `alpha` sur
#' fond blanc (pour les fonds d'étiquettes, qui doivent rester opaques).
teinte_claire <- function(couleur, alpha) {
  grDevices::rgb(t(1 - alpha * (1 - grDevices::col2rgb(couleur) / 255)))
}

#' Dépense P × Q avant et après la hausse de 10 € à 12 € (exemple 1, e = -0,4).
#' La demande linéaire Q = 140 - 4 P (celle du marché A de l'exemple 2) passe
#' par (100 ; 10) et (92 ; 12). Rectangle gagné : (12 - 10) × 92 = 184 M€ ;
#' rectangle perdu : 10 × (100 - 92) = 80 M€. Graduations chiffrées assumées :
#' la figure illustre l'exemple chiffré.
graphe_depense <- function(base_size = 16) {
  e <- ex1_cm2
  q <- seq(60, 130, length.out = 30)
  d <- data.frame(q = q, p = (140 - q) / 4)
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  ggplot(d, aes(q, p)) +
    annotate("rect", xmin = 0, xmax = e$q1_faible, ymin = e$p0, ymax = e$p1,
             fill = couleurs_eco[["demande"]], alpha = 0.25) +
    annotate("rect", xmin = e$q1_faible, xmax = e$q0, ymin = 0, ymax = e$p0,
             fill = couleurs_eco[["alerte"]], alpha = 0.25) +
    annotate("segment", x = c(0, e$q0, e$q1_faible), xend = c(e$q0, e$q0, e$q1_faible),
             y = c(e$p0, 0, 0), yend = c(e$p0, e$p0, e$p1), linetype = "22", colour = neutre) +
    geom_line(colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    annotate("point", x = c(e$q0, e$q1_faible), y = c(e$p0, e$p1), size = 3,
             colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = 46, y = (e$p0 + e$p1) / 2, label = "+ 184", family = police_cours,
             size = taille, colour = couleurs_eco[["demande"]]) +
    annotate("text", x = 103, y = 3, label = "− 80", hjust = 0, family = police_cours,
             size = taille, colour = couleurs_eco[["alerte"]]) +
    annotate("text", x = 72, y = 19, label = "D", family = police_cours, size = taille,
             colour = couleurs_eco[["demande"]]) +
    # diapos : 92 et 100 sont trop proches à base_size 24, on les décale sur deux lignes
    scale_x_continuous(breaks = c(e$q1_faible, e$q0), labels = c("92", "100"),
                       guide = if (base_size > 16) guide_axis(n.dodge = 2) else "axis") +
    scale_y_continuous(breaks = c(e$p0, e$p1), labels = c("10", "12")) +
    coord_cartesian(xlim = c(0, 130), ylim = c(0, 20), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q (millions de paquets)", y = "Prix P (€ par paquet)") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 2. Exemple 2 de la page : incidence d'une taxe de 5 € par paquet (marché fictif)
#    Q en millions de paquets, P en euros.
#    Offre (les deux panneaux)       : Q = -60 + 16 P   (élasticité 1,6 au départ)
#    Demande A, peu élastique        : Q = 140 - 4 P    (e = -0,4 au départ)
#    Demande B, plus élastique       : Q = 260 - 16 P   (e = -1,6 au départ)
#    Sans taxe, les deux marchés sont en (P* = 10 €, Q* = 100).
# ---------------------------------------------------------------------------
marche_cm2 <- list(o_c = -60, o_s = 16,
                   a_a = 140, a_b = 4,
                   b_a = 260, b_b = 16,
                   t = 5)

eq_a0 <- equilibre_taxe(marche_cm2$a_a, marche_cm2$a_b, marche_cm2$o_c, marche_cm2$o_s)
eq_a1 <- equilibre_taxe(marche_cm2$a_a, marche_cm2$a_b, marche_cm2$o_c, marche_cm2$o_s, marche_cm2$t)
eq_b0 <- equilibre_taxe(marche_cm2$b_a, marche_cm2$b_b, marche_cm2$o_c, marche_cm2$o_s)
eq_b1 <- equilibre_taxe(marche_cm2$b_a, marche_cm2$b_b, marche_cm2$o_c, marche_cm2$o_s, marche_cm2$t)

#' Part de la taxe supportée par les acheteurs : hausse du prix payé ÷ t
part_acheteurs <- function(eq0, eq1, t) (eq1$p - eq0$p) / t

# ---------------------------------------------------------------------------
# 3. Graphique théorique : incidence d'une taxe unitaire t (demande peu élastique)
# ---------------------------------------------------------------------------

#' Une taxe t versée par le vendeur déplace l'offre vers le haut de t (O -> O').
#' Le coin fiscal sépare le prix payé par l'acheteur (P*') du prix gardé par le
#' vendeur (P*' - t). Rectangles : part de la recette fiscale supportée par les
#' acheteurs (azur) et par les vendeurs (ambre). Axes sans graduations chiffrées.
#' La géométrie est celle du marché A de l'exemple 2.
graphe_incidence <- function(base_size = 16) {
  m <- marche_cm2
  q <- seq(50, 125, length.out = 60)
  d <- data.frame(q = q,
                  demande = (m$a_a - q) / m$a_b,
                  offre   = (q - m$o_c) / m$o_s,
                  offre2  = (q - m$o_c) / m$o_s + m$t)
  p0 <- eq_a0$p; q0 <- eq_a0$q; p1 <- eq_a1$p; pv <- eq_a1$pv; q1 <- eq_a1$q
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  ggplot(d, aes(q)) +
    # rectangles de la recette fiscale : acheteurs au-dessus de P*, vendeurs au-dessous
    annotate("rect", xmin = 50, xmax = q1, ymin = p0, ymax = p1,
             fill = couleurs_eco[["demande"]], alpha = 0.18) +
    annotate("rect", xmin = 50, xmax = q1, ymin = pv, ymax = p0,
             fill = couleurs_eco[["offre"]], alpha = 0.22) +
    annotate("segment", x = c(q0, 50, q1, 50, 50), xend = c(q0, q0, q1, q1, q1),
             y = c(5, p0, 5, p1, pv), yend = c(p0, p0, p1, p1, pv),
             linetype = "22", colour = neutre) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    geom_line(aes(y = offre2), colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22") +
    # le coin fiscal t, entre le prix payé et le prix gardé, à la quantité Q*'
    annotate("segment", x = q1, xend = q1, y = pv, yend = p1,
             colour = couleurs_eco[["alerte"]], linewidth = 1.6) +
    annotate("text", x = q1 + 1.8, y = (pv + p1) / 2 - 0.9, label = "t", hjust = 0,
             colour = couleurs_eco[["alerte"]], family = police_cours, size = taille) +
    # étiquettes sur fond blanc : la courbe O' traverse le rectangle des acheteurs
    annotate("label", x = 51.5, y = c(p0 + 0.8, (pv + p0) / 2),
             label = c("payé par les acheteurs", "payé par les vendeurs"),
             hjust = 0, family = police_cours, size = taille * 0.8, colour = couleurs_eco[["equilibre"]],
             fill = c(teinte_claire(couleurs_eco[["demande"]], 0.12),
                      teinte_claire(couleurs_eco[["offre"]], 0.16)), border.colour = NA, label.padding = grid::unit(0.1, "lines")) +
    annotate("point", x = c(q0, q1), y = c(p0, p1), size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = c(q0 + 2.2, q1 - 2.6), y = c(p0 - 0.35, p1 + 0.6), label = c("E", "E′"),
             family = police_cours, size = taille) +
    annotate("text", x = c(66, 122, 108), y = c(19.2, 11.9, 17.2), label = c("D", "O", "O′ = O + t"),
             colour = couleurs_eco[c("demande", "offre", "offre")], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(q1, q0), labels = c("Q*′", "Q*")) +
    scale_y_continuous(breaks = c(pv, p0, p1), labels = c("P*′ − t", "P*", "P*′")) +
    coord_cartesian(xlim = c(50, 125), ylim = c(5, 20), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q", y = "Prix P") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 4. Graphique de l'exemple 2 : même taxe, deux demandes
# ---------------------------------------------------------------------------

#' Deux panneaux : demande peu élastique (A) et plus élastique (B), même offre O,
#' même taxe t = 5 € (O -> O'). Graduations chiffrées assumées : la figure
#' illustre l'exemple chiffré (prix 7,5 ; 9 ; 10 ; 12,5 ; 14 € ; quantités 60, 84, 100).
graphe_incidence_elasticite <- function(base_size = 16) {
  m <- marche_cm2
  q <- seq(40, 125, length.out = 60)
  panneaux <- c("A. Demande peu élastique (e = −0,4)", "B. Demande plus élastique (e = −1,6)")
  if (base_size > 16) panneaux <- c("A. e = −0,4", "B. e = −1,6")   # diapos : titres courts, sinon coupés
  d <- rbind(
    data.frame(panneau = panneaux[1], q = q, demande = (m$a_a - q) / m$a_b),
    data.frame(panneau = panneaux[2], q = q, demande = (m$b_a - q) / m$b_b)
  )
  d$offre  <- (d$q - m$o_c) / m$o_s
  d$offre2 <- d$offre + m$t
  d$panneau <- factor(d$panneau, levels = panneaux)
  fp <- function(x) factor(panneaux[x], levels = panneaux)
  pts <- data.frame(panneau = fp(c(1, 1, 2, 2)),
                    q = c(eq_a0$q, eq_a1$q, eq_b0$q, eq_b1$q),
                    p = c(eq_a0$p, eq_a1$p, eq_b0$p, eq_b1$p))
  coins <- data.frame(panneau = fp(1:2), q = c(eq_a1$q, eq_b1$q),
                      pv = c(eq_a1$pv, eq_b1$pv), p = c(eq_a1$p, eq_b1$p))
  etiquettes <- data.frame(
    panneau = fp(c(1, 1, 1, 2, 2, 2, 1, 2)),
    q = c(72, 120, 105, 112, 120, 105, eq_a1$q - 3.5, eq_b1$q - 3.5),
    p = c(18.8, 10.2, 16.8, 8.2, 10.2, 16.8, 5.7, 5.7),
    # les deux dernières : quantité après taxe, propre à chaque panneau
    # (l'axe commun aux deux panneaux ne gradue que Q* = 100)
    lab = c("D", "O", "O′", "D", "O", "O′", "84", "60"),
    col = unname(couleurs_eco[c("demande", "offre", "offre", "demande", "offre", "offre",
                                "equilibre", "equilibre")])
  )
  ggplot(d, aes(q)) +
    geom_segment(data = pts, aes(x = q, xend = q, y = 5, yend = p),
                 linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_segment(data = pts, aes(x = 40, xend = q, y = p, yend = p),
                 linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_segment(data = coins, aes(x = 40, xend = q, y = pv, yend = pv),
                 linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    geom_line(aes(y = offre2), colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22") +
    geom_segment(data = coins, aes(x = q, xend = q, y = pv, yend = p),
                 colour = couleurs_eco[["alerte"]], linewidth = 1.6) +
    geom_point(data = pts, aes(y = p), size = 2.6, colour = couleurs_eco[["equilibre"]]) +
    geom_text(data = etiquettes, aes(x = q, y = p, label = lab, colour = col),
              family = police_cours, size = base_size / 3) +
    scale_colour_identity() +
    facet_wrap(~panneau, nrow = 1) +
    scale_x_continuous(breaks = 100, labels = "100") +
    scale_y_continuous(breaks = c(7.5, 9, 10, 12.5, 14), labels = c("7,5", "9", "10", "12,5", "14")) +
    coord_cartesian(xlim = c(40, 125), ylim = c(5, 20), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q (millions de paquets)", y = "Prix P (€ par paquet)") +
    theme_cours(base_size = base_size) +
    theme(strip.text = element_text(family = police_cours, hjust = 0, size = rel(0.75)),
          panel.spacing = grid::unit(1.5, "lines"),
          axis.text.x = element_text(size = rel(0.8)), axis.text.y = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 5. Graphique théorique : demande de court terme et de long terme (addiction)
#    Valeurs fictives de l'encadré : hausse de prix de 20 %,
#    e = -0,3 à un an (court terme), e = -0,6 à plusieurs années (long terme).
# ---------------------------------------------------------------------------
addiction_cm2 <- list(p0 = 10, p1 = 12, q0 = 100, e_ct = -0.3, e_lt = -0.6)

#' Deux demandes linéaires passant par (Q* = 100, P* = 10) avec l'élasticité
#' demandée en ce point : pente b = -e Q / P.
demande_par_point <- function(e, q0 = 100, p0 = 10) {
  b <- -e * q0 / p0
  list(a = q0 + b * p0, b = b)
}

#' La demande de long terme est plus plate que celle de court terme : la même
#' hausse de prix (P* -> P*') réduit peu la quantité la première année (Q*CT)
#' et davantage à long terme (Q*LT). Axes sans graduations chiffrées.
graphe_court_long <- function(base_size = 16) {
  a <- addiction_cm2
  ct <- demande_par_point(a$e_ct); lt <- demande_par_point(a$e_lt)
  q_ct <- ct$a - ct$b * a$p1; q_lt <- lt$a - lt$b * a$p1
  p <- seq(7, 14.5, length.out = 40)
  d <- data.frame(p = p, q_ct = ct$a - ct$b * p, q_lt = lt$a - lt$b * p)
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  ggplot(d) +
    annotate("segment", x = c(a$q0, q_ct, q_lt, 70), xend = c(a$q0, q_ct, q_lt, q_ct),
             y = c(6, 6, 6, a$p1), yend = c(a$p0, a$p1, a$p1, a$p1),
             linetype = "22", colour = neutre) +
    annotate("segment", x = 70, xend = a$q0, y = a$p0, yend = a$p0, linetype = "22", colour = neutre) +
    geom_line(aes(q_ct, p), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    # long terme : trait plein plus fin (les tirets sont réservés aux courbes déplacées, § 7)
    geom_line(aes(q_lt, p), colour = couleurs_eco[["demande"]], linewidth = 0.7) +
    annotate("point", x = c(a$q0, q_ct, q_lt), y = c(a$p0, a$p1, a$p1), size = 3,
             colour = couleurs_eco[["equilibre"]]) +
    # « D long terme » sous P*', à gauche de la courbe fine, pour ne pas la toucher
    annotate("text", x = c(93.5, 71.5), y = c(14.2, 11.2),
             label = c("D court terme", "D long terme"), hjust = c(0, 0),
             colour = couleurs_eco[["demande"]], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(q_lt, q_ct, a$q0), labels = c("Q*LT", "Q*CT", "Q*")) +
    scale_y_continuous(breaks = c(a$p0, a$p1), labels = c("P*", "P*′")) +
    coord_cartesian(xlim = c(70, 115), ylim = c(6, 15), expand = FALSE, clip = "on") +
    labs(x = "Quantité Q", y = "Prix P") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 6. Exemple 3 de la page : où vont les 13,50 € d'un paquet ?
#    Hill (2026), tableau 5.2 (taux au 1er janvier 2026, prix du 1er février 2026)
#    et tableau 6 (remise brute du buraliste en 2025 : 10,29 % du prix).
# ---------------------------------------------------------------------------
paquet_cm2 <- list(prix = 13.50, accise_prop = 0.55, accise_spec = 1.466,
                   tva = 0.20 / 1.20, remise = 0.1029)
paquet_cm2$accise <- paquet_cm2$accise_prop * paquet_cm2$prix + paquet_cm2$accise_spec
paquet_cm2$tva_e  <- paquet_cm2$tva * paquet_cm2$prix
paquet_cm2$taxes  <- paquet_cm2$accise + paquet_cm2$tva_e
paquet_cm2$buraliste <- paquet_cm2$remise * paquet_cm2$prix
paquet_cm2$fabricant <- paquet_cm2$prix - paquet_cm2$taxes - paquet_cm2$buraliste

# ---------------------------------------------------------------------------
# 7. Graphique de données : recettes du droit de consommation sur les tabacs
#    Hill (2026), tableau 6, France continentale, 1991-2025.
#    Fichier et provenance : data/cm2/droit_consommation_tabac.csv et data/cm2/SOURCES.md
# ---------------------------------------------------------------------------
recettes_cm2 <- utils::read.csv(here::here("data/cm2/droit_consommation_tabac.csv"))
recettes_cm2$constant_mds <- recettes_cm2$courant_mds * 100 / recettes_cm2$indice_prix

#' Recette (Md€) d'une année, en euros courants ou constants
recette_annee <- function(annee, serie = "courant_mds") recettes_cm2[[serie]][recettes_cm2$annee == annee]

#' Droit de consommation sur les tabacs, en milliards d'euros courants et
#' constants (prix de 2001), 1991-2025.
graphe_recettes_tabac <- function(base_size = 16) {
  d <- rbind(
    data.frame(annee = recettes_cm2$annee, serie = "Euros courants", mds = recettes_cm2$courant_mds),
    data.frame(annee = recettes_cm2$annee, serie = "Euros constants (prix de 2001)", mds = recettes_cm2$constant_mds)
  )
  d$serie <- factor(d$serie, levels = c("Euros courants", "Euros constants (prix de 2001)"))
  ggplot(d, aes(annee, mds, colour = serie)) +
    annotate("segment", x = 2020, xend = 2020, y = 0, yend = 15.5,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    # étiquette sous les courbes, dans la zone vide de 2010 à 2019
    annotate("text", x = 2018.8, y = 6, label = "2020 : sommet\n(frontières fermées)", hjust = 1, vjust = 1,
             family = police_cours, size = base_size / 3.4, colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.2) +
    scale_colour_manual(values = ordre_series[1:2]) +
    scale_x_continuous(breaks = seq(1995, 2025, 5)) +
    scale_y_continuous(breaks = seq(0, 15, 5), labels = function(x) format(x, decimal.mark = ",")) +
    coord_cartesian(ylim = c(0, 16)) +
    labs(x = NULL, y = "Milliards d'euros",
         caption = "Source : C. Hill (2026), Impact de l'augmentation des prix\nsur la consommation de tabac, tableau 6.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 7b. Graphique de données : prix, quantités et dépense de tabac des ménages,
#     France, 2000-2025 (Insee, comptes nationaux base 2020 ; Eurostat, IPCH).
#     Fichier et provenance : data/cm2/consommation_tabac_insee.csv et data/cm2/SOURCES.md
# ---------------------------------------------------------------------------
conso_cm2 <- utils::read.csv(here::here("data/cm2/consommation_tabac_insee.csv"))

#' Rapport entre la valeur de `serie` en `a1` et en `a0` (ex. 4,6 = « multiplié par 4,6 »)
conso_rapport <- function(serie, a0 = 2000, a1 = 2025) {
  conso_cm2[[serie]][conso_cm2$annee == a1] / conso_cm2[[serie]][conso_cm2$annee == a0]
}

#' Prix du tabac, quantités achetées (volume) et dépense des ménages en euros
#' courants, en indices base 100 en 2000. La dépense est (à l'arrondi près) le
#' produit du prix par le volume : la figure montre P, Q et P × Q.
graphe_conso_tabac <- function(base_size = 16) {
  base <- function(x) 100 * x / x[conso_cm2$annee == 2000]
  series <- c("Prix", "Quantités (volume)", "Dépense (€ courants)")
  d <- rbind(
    data.frame(annee = conso_cm2$annee, serie = series[1], indice = base(conso_cm2$prix_indice_2020)),
    data.frame(annee = conso_cm2$annee, serie = series[2], indice = base(conso_cm2$volume_meur2020)),
    data.frame(annee = conso_cm2$annee, serie = series[3], indice = base(conso_cm2$depense_meur_courants))
  )
  d$serie <- factor(d$serie, levels = series)
  ggplot(d, aes(annee, indice, colour = serie)) +
    geom_hline(yintercept = 100, linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.2) +
    scale_colour_manual(values = ordre_series[1:3]) +
    scale_x_continuous(breaks = seq(2000, 2025, 5)) +
    scale_y_continuous(breaks = seq(0, 500, 100)) +
    coord_cartesian(ylim = c(0, 500)) +
    labs(x = NULL, y = "Indice (2000 = 100)",
         caption = "Source : Insee, comptes nationaux annuels\n(base 2020), mai 2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 8. Vérifications : chaque chiffre annoncé dans cours/cm2.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# Exemple 1 : +20 % de prix ; e = -0,4 -> 92 millions de paquets, dépense 1 000 -> 1 104 M€ (+10,4 %) ;
# e = -1,5 -> 70 millions, dépense 840 M€ (-16 %)
stopifnot(
  proche(var_pct(ex1_cm2$p0, ex1_cm2$p1), 20),
  proche(ex1_cm2$q1_faible, 92), proche(ex1_cm2$p1 * ex1_cm2$q1_faible, 1104),
  proche(var_pct(ex1_cm2$p0 * ex1_cm2$q0, ex1_cm2$p1 * ex1_cm2$q1_faible), 10.4),
  proche(ex1_cm2$q1_forte, 70), proche(ex1_cm2$p1 * ex1_cm2$q1_forte, 840),
  proche(var_pct(ex1_cm2$p0 * ex1_cm2$q0, ex1_cm2$p1 * ex1_cm2$q1_forte), -16)
)
# Exemple 2, marché A : (10 ; 100) -> acheteur 14 €, vendeur 9 €, Q = 84 ; 80 % pour les acheteurs ;
# recette 420 M€ dont 336 (acheteurs) et 84 (vendeurs) ; dépense 1 000 -> 1 176 ; e = -16 % / +40 % = -0,4
stopifnot(
  proche(eq_a0$p, 10), proche(eq_a0$q, 100),
  proche(eq_a1$p, 14), proche(eq_a1$pv, 9), proche(eq_a1$q, 84),
  proche(part_acheteurs(eq_a0, eq_a1, marche_cm2$t), 0.8),
  proche(marche_cm2$t * eq_a1$q, 420),
  proche((eq_a1$p - eq_a0$p) * eq_a1$q, 336), proche((eq_a0$p - eq_a1$pv) * eq_a1$q, 84),
  proche(eq_a1$p * eq_a1$q, 1176),
  proche(var_pct(eq_a0$q, eq_a1$q), -16), proche(var_pct(eq_a0$p, eq_a1$p), 40),
  proche(var_pct(eq_a0$q, eq_a1$q) / var_pct(eq_a0$p, eq_a1$p), -0.4),
  # élasticités au point de départ : demande -0,4, offre 1,6 ; règle Es / (Es + |e|) = 0,8,
  # égale à la part payée par les acheteurs calculée sur l'équilibre
  proche(-marche_cm2$a_b * 10 / 100, -0.4), proche(marche_cm2$o_s * 10 / 100, 1.6),
  proche((marche_cm2$o_s * 10 / 100) / (marche_cm2$o_s * 10 / 100 + marche_cm2$a_b * 10 / 100),
         part_acheteurs(eq_a0, eq_a1, marche_cm2$t))
)
# Exemple 2, marché B : (10 ; 100) -> acheteur 12,5 €, vendeur 7,5 €, Q = 60 ; 50/50 ; recette 300 M€
stopifnot(
  proche(eq_b0$p, 10), proche(eq_b0$q, 100),
  proche(eq_b1$p, 12.5), proche(eq_b1$pv, 7.5), proche(eq_b1$q, 60),
  proche(part_acheteurs(eq_b0, eq_b1, marche_cm2$t), 0.5),
  proche(marche_cm2$t * eq_b1$q, 300),
  proche(-marche_cm2$b_b * 10 / 100, -1.6),
  proche((marche_cm2$o_s * 10 / 100) / (marche_cm2$o_s * 10 / 100 + marche_cm2$b_b * 10 / 100),
         part_acheteurs(eq_b0, eq_b1, marche_cm2$t)),   # règle Es / (Es + |e|) = 0,5
  proche(var_pct(eq_b0$q, eq_b1$q), -40), proche(var_pct(eq_b0$p, eq_b1$p), 25)
)
# Figure de l'exemple 1 et passage court terme / long terme (valeurs fictives)
stopifnot(
  # figure de l'exemple 1 : rectangle gagné 184, perdu 80, solde 104
  proche((ex1_cm2$p1 - ex1_cm2$p0) * ex1_cm2$q1_faible, 184),
  proche(ex1_cm2$p0 * (ex1_cm2$q0 - ex1_cm2$q1_faible), 80),
  proche((140 - 4 * ex1_cm2$p1), ex1_cm2$q1_faible),   # la demande tracée passe bien par (92 ; 12)
  # court / long terme : +20 % -> -6 % la première année, -12 % ensuite
  proche(addiction_cm2$e_ct * 20, -6), proche(addiction_cm2$e_lt * 20, -12),
  proche(with(demande_par_point(addiction_cm2$e_ct), a - b * 12), 94),
  proche(with(demande_par_point(addiction_cm2$e_lt), a - b * 12), 88)
)
# Exemple 3 : paquet à 13,50 € (Hill 2026, tableau 5.2)
stopifnot(
  proche(round(paquet_cm2$accise_prop * paquet_cm2$prix, 2), 7.43),
  proche(paquet_cm2$accise, 8.891),
  proche(paquet_cm2$tva_e, 2.25),
  proche(round(paquet_cm2$taxes, 2), 11.14),
  proche(round(100 * paquet_cm2$taxes / paquet_cm2$prix, 1), 82.5),
  proche(round(paquet_cm2$prix - paquet_cm2$taxes, 2), 2.36),
  proche(round(paquet_cm2$buraliste, 2), 1.39),
  proche(round(paquet_cm2$fabricant, 2), 0.97),
  proche(round(100 * paquet_cm2$fabricant / paquet_cm2$prix, 1), 7.2),   # Hill, figure 5.3 : 7,2 %
  proche(round(paquet_cm2$accise_prop + paquet_cm2$tva, 2), 0.72),       # sur 1 € de hausse du prix
  proche(round(paquet_cm2$remise, 2), 0.10),                             # dont buraliste
  proche(round(1 - paquet_cm2$accise_prop - paquet_cm2$tva - paquet_cm2$remise, 2), 0.18)  # fabricant
)
# Données : droit de consommation 2020 -> 2025 (Hill, tableau 6)
stopifnot(
  nrow(recettes_cm2) == 35, !anyNA(recettes_cm2),
  proche(recette_annee(2020), 14.35), proche(recette_annee(2025), 12.74),
  proche(recette_annee(2020), max(recettes_cm2$courant_mds)),
  proche(round(var_pct(recette_annee(2020), recette_annee(2025)), 0), -11),
  proche(round(var_pct(recette_annee(2020, "constant_mds"), recette_annee(2025, "constant_mds")), 0), -23),
  proche(round(recette_annee(2025, "constant_mds"), 2), 8.50),     # valeur publiée : 8,50
  proche(round(recette_annee(2020, "constant_mds"), 2), 11.01),    # valeur publiée : 11,01
  proche(round(recette_annee(2020) / recette_annee(1991), 1), 4.4),
  # base 2019, avant le pic du Covid : 12,60 -> 12,74 (stable, +1 %) ; -13 % en euros constants
  proche(recette_annee(2019), 12.60),
  proche(round(var_pct(recette_annee(2019), recette_annee(2025)), 0), 1),
  proche(round(var_pct(recette_annee(2019, "constant_mds"), recette_annee(2025, "constant_mds")), 0), -13)
)
# Faits cités dans la page (sources dans le texte)
stopifnot(
  proche(round(var_pct(32846, 30165), 1), -8.2)      # OFDT, ventes 2024 -> 2025
)
# Données : prix, quantités et dépense de tabac des ménages, 2000 -> 2025 (Insee ; Eurostat pour l'IPCH)
# Prix x 4,6 (+359 %), quantités / 2,8 (-64 %), dépense +64 % en euros courants ;
# prix général (IPCH) +59 % ; prix réel du tabac x 2,9 ; dépense corrigée de l'inflation +3 %
stopifnot(
  nrow(conso_cm2) == 26, !anyNA(conso_cm2), identical(range(conso_cm2$annee), c(2000L, 2025L)),
  # la dépense en euros courants est bien prix x volume (à 0,5 % près, arrondis de l'Insee)
  all(abs(conso_cm2$prix_indice_2020 * conso_cm2$volume_meur2020 / 100 / conso_cm2$depense_meur_courants - 1) < 0.005),
  proche(round(conso_rapport("prix_indice_2020"), 1), 4.6),
  # indices 2025 lus sur la figure (base 100 en 2000) : prix 459, quantités 36, dépense 164
  proche(round(100 * conso_rapport("prix_indice_2020")), 459),
  proche(round(100 * conso_rapport("volume_meur2020")), 36),
  proche(round(100 * conso_rapport("depense_meur_courants")), 164),
  proche(round(100 * (conso_rapport("prix_indice_2020") - 1), 0), 359),
  proche(round(1 / conso_rapport("volume_meur2020"), 1), 2.8),
  proche(round(100 * (conso_rapport("volume_meur2020") - 1), 0), -64),
  proche(round(100 * (conso_rapport("depense_meur_courants") - 1), 0), 64),
  proche(round(100 * (conso_rapport("ihpc_ensemble_2015") - 1), 0), 59),
  proche(round(conso_rapport("prix_indice_2020") / conso_rapport("ihpc_ensemble_2015"), 1), 2.9),
  proche(round(100 * (conso_rapport("depense_meur_courants") / conso_rapport("ihpc_ensemble_2015") - 1), 0), 3),
  # 2020 : le volume ne baisse presque pas (frontières fermées), 24 772 -> 24 726 M€ de 2020
  proche(round(var_pct(conso_cm2$volume_meur2020[conso_cm2$annee == 2019],
                       conso_cm2$volume_meur2020[conso_cm2$annee == 2020]), 1), -0.2)
)
