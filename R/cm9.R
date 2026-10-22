# cm9.R · graphiques du CM 9 (à quoi servent les droits de douane ?),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm9.qmd sont définies ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.

proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# ---------------------------------------------------------------------------
# 1. Avantage comparatif (Exemple 1 de la page) : deux pays fictifs, A et B,
#    deux biens, blé (tonnes) et vêtements (lots). Le travail est le seul facteur.
#    Heures de travail nécessaires pour produire une unité :
#      A : blé 2 h, vêtements 4 h, 120 h disponibles ;
#      B : blé 12 h, vêtements 6 h, 240 h disponibles.
#    A est plus productif pour les deux biens (avantage absolu partout),
#    mais B a un avantage comparatif dans les vêtements.
#    Autarcie : chaque pays consacre la moitié de ses heures à chaque bien.
#    Échange : 1 lot de vêtements contre 1 tonne de blé, 20 contre 20.
# ---------------------------------------------------------------------------
ricardo_cm9 <- data.frame(
  pays = c("A", "B"),
  h_ble = c(2, 12), h_vet = c(4, 6), heures = c(120, 240)
)
ricardo_cm9$max_ble <- ricardo_cm9$heures / ricardo_cm9$h_ble   # tout en blé
ricardo_cm9$max_vet <- ricardo_cm9$heures / ricardo_cm9$h_vet   # tout en vêtements
ricardo_cm9$co_vet  <- ricardo_cm9$h_vet / ricardo_cm9$h_ble    # coût d'opportunité d'un lot de vêtements, en tonnes de blé
ricardo_cm9$aut_ble <- ricardo_cm9$heures / 2 / ricardo_cm9$h_ble
ricardo_cm9$aut_vet <- ricardo_cm9$heures / 2 / ricardo_cm9$h_vet
echange_cm9 <- 20   # A vend 20 t de blé à B contre 20 lots de vêtements
ricardo_cm9$con_ble <- c(ricardo_cm9$max_ble[1] - echange_cm9, echange_cm9)   # A : produit 60, vend 20 ; B : achète 20
ricardo_cm9$con_vet <- c(echange_cm9, ricardo_cm9$max_vet[2] - echange_cm9)   # A : achète 20 ; B : produit 40, vend 20

#' Frontières de production de A et de B (droites), point d'autarcie (cercle
#' vide) et consommation après spécialisation et échange (point plein, hors
#' de la frontière). Graduations chiffrées assumées : la figure illustre
#' l'exemple chiffré.
#' @param etape construction pas à pas pour les diapos : 1 = frontières seules ;
#'   2 = ajoute l'autarcie ; 3 = figure complète (échange), identique à celle de
#'   la page (valeur par défaut)
graphe_ricardo <- function(base_size = 16, etape = 3) {
  r <- ricardo_cm9
  r$panneau <- factor(paste("Pays", r$pays), levels = c("Pays A", "Pays B"))
  frontiere <- data.frame(panneau = rep(r$panneau, each = 2),
                          vet = c(0, r$max_vet[1], 0, r$max_vet[2]),
                          ble = c(r$max_ble[1], 0, r$max_ble[2], 0))
  taille <- base_size / 3.2
  g <- ggplot() +
    geom_line(data = frontiere, aes(vet, ble), colour = couleurs_eco[["neutre"]], linewidth = 1.3)
  if (etape >= 3) g <- g +
    geom_segment(data = r, aes(x = aut_vet, y = aut_ble, xend = con_vet, yend = con_ble),
                 colour = couleurs_eco[["demande"]], linewidth = 0.7,
                 arrow = grid::arrow(length = grid::unit(0.22, "cm"), type = "closed"))
  if (etape >= 2) g <- g +
    geom_point(data = r, aes(aut_vet, aut_ble), shape = 21, fill = "white",
               colour = couleurs_eco[["equilibre"]], size = 3, stroke = 1.1)
  if (etape >= 3) g <- g +
    geom_point(data = r, aes(con_vet, con_ble), colour = couleurs_eco[["demande"]], size = 3.2)
  # à droite du point, pour ne pas déborder sur l'axe vertical du pays A
  # « autarcie » à droite du point (pas de débordement sur l'axe vertical) et du côté
  # où la frontière ne barre pas le mot : en dessous pour A (au-delà de la droite,
  # sous la flèche), au-dessus pour B (frontière peu pentue)
  if (etape >= 2) g <- g +
    geom_text(data = r, aes(aut_vet + c(4, 1), aut_ble + c(-4, 3), label = "autarcie"),
              hjust = 0, family = police_cours, size = taille, colour = couleurs_eco[["equilibre"]])
  if (etape >= 3) g <- g +
    geom_text(data = r, aes(con_vet, con_ble, label = "avec échange"), nudge_x = 1.2, nudge_y = 2.6,
              hjust = 0, family = police_cours, size = taille, colour = couleurs_eco[["demande"]])
  g +
    facet_wrap(~panneau, nrow = 1, axes = "all") +   # axe vertical tracé dans les deux panneaux
    scale_x_continuous(breaks = c(0, 10, 20, 30, 40)) +
    scale_y_continuous(breaks = c(0, 10, 20, 30, 40, 50, 60)) +
    coord_cartesian(xlim = c(0, 45), ylim = c(0, 65), expand = FALSE, clip = "off") +
    labs(x = "Vêtements (lots)", y = "Blé (tonnes)") +
    theme_cours(base_size = base_size) +
    theme(strip.text = element_text(family = police_cours, hjust = 0, size = rel(0.9)),
          panel.spacing = grid::unit(2, "lines"),
          axis.text = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 2. Droit de douane dans un petit pays (Exemple 2 de la page)
#    Marché intérieur fictif de tee-shirts, P en euros, Q en millions par an.
#    Demande intérieure : Qd = 100 - P ; offre intérieure : Qo = P.
#    Prix mondial Pw = 20 € (le pays est trop petit pour l'influencer) ;
#    droit de douane unitaire t = 10 € par tee-shirt.
# ---------------------------------------------------------------------------
tarif_cm9 <- list(d_a = 100, pm = 20, t = 10)
qd_cm9 <- function(p) tarif_cm9$d_a - p
qo_cm9 <- function(p) p
p_avec_cm9 <- tarif_cm9$pm + tarif_cm9$t
imports_sans_cm9 <- qd_cm9(tarif_cm9$pm) - qo_cm9(tarif_cm9$pm)   # 80 - 20 = 60
imports_avec_cm9 <- qd_cm9(p_avec_cm9) - qo_cm9(p_avec_cm9)       # 70 - 30 = 40
# Aires (millions d'euros), notations de la figure : a, b, c, d
aire_a_cm9 <- (qo_cm9(tarif_cm9$pm) + qo_cm9(p_avec_cm9)) / 2 * tarif_cm9$t   # gain des producteurs
aire_b_cm9 <- (qo_cm9(p_avec_cm9) - qo_cm9(tarif_cm9$pm)) * tarif_cm9$t / 2   # perte sèche (production)
aire_c_cm9 <- imports_avec_cm9 * tarif_cm9$t                                    # recette de l'État
aire_d_cm9 <- (qd_cm9(tarif_cm9$pm) - qd_cm9(p_avec_cm9)) * tarif_cm9$t / 2   # perte sèche (consommation)
perte_conso_cm9 <- (qd_cm9(tarif_cm9$pm) + qd_cm9(p_avec_cm9)) / 2 * tarif_cm9$t   # perte des consommateurs

#' Droit de douane dans un petit pays : demande et offre intérieures, prix
#' mondial Pw et prix intérieur Pw + t, aires a, b, c, d.
#' @param chiffres TRUE : graduations de l'exemple chiffré ; FALSE : graphique
#'   théorique, seuls Pw et Pw + t sont étiquetés
#' @param base_size 16 (page) ou 24 (diapos)
#' @param etape construction pas à pas pour les diapos : 1 = libre-échange
#'   (Pw, Q₁, Q₄, importations sans droit) ; 2 = ajoute le droit (Pw + t, Q₂, Q₃,
#'   importations avec droit) ; 3 = ajoute les transferts (aires a et c) ;
#'   4 = figure complète (pertes sèches b et d), identique à celle de la page
#'   (valeur par défaut)
graphe_tarif <- function(chiffres = TRUE, base_size = 16, etape = 4) {
  pm <- tarif_cm9$pm; pt <- p_avec_cm9
  q1 <- qo_cm9(pm); q2 <- qo_cm9(pt); q3 <- qd_cm9(pt); q4 <- qd_cm9(pm)
  i_p <- if (etape >= 2) 1:2 else 1            # Pw seul, ou Pw et Pw + t
  i_q <- if (etape >= 2) 1:4 else c(1, 4)      # Q₁, Q₄ (puis Q₂, Q₃)
  i_aire <- if (etape >= 4) c("a", "b", "c", "d") else c("a", "c")   # transferts, puis pertes sèches
  aires <- rbind(
    data.frame(aire = "a", x = c(0, q1, q2, 0), y = c(pm, pm, pt, pt)),
    data.frame(aire = "b", x = c(q1, q2, q2), y = c(pm, pt, pm)),
    data.frame(aire = "c", x = c(q2, q3, q3, q2), y = c(pm, pm, pt, pt)),
    data.frame(aire = "d", x = c(q3, q4, q3), y = c(pm, pm, pt))
  )
  remplissage <- c(a = couleurs_eco[["offre"]], b = couleurs_eco[["alerte"]],
                   c = couleurs_eco[["neutre"]], d = couleurs_eco[["alerte"]])
  centres <- data.frame(aire = c("a", "b", "c", "d"),
                        x = c(q1 * 0.6, q1 + (q2 - q1) * 0.67, (q2 + q3) / 2, q3 + (q4 - q3) * 0.33),
                        y = c((pm + pt) / 2, pm + (pt - pm) * 0.33, (pm + pt) / 2, pm + (pt - pm) * 0.33))
  aires <- aires[aires$aire %in% i_aire, ]
  centres <- centres[centres$aire %in% i_aire, ]
  taille <- base_size / 3
  q <- seq(0, 100, length.out = 2)
  courbes <- data.frame(q = q, demande = tarif_cm9$d_a - q, offre = q)
  g <- ggplot()
  if (etape >= 3) g <- g +
    geom_polygon(data = aires, aes(x, y, group = aire, fill = aire), alpha = 0.35) +
    scale_fill_manual(values = remplissage) +
    geom_text(data = centres, aes(x, y, label = aire), family = police_cours,
              fontface = "italic", size = taille)
  g <- g +
    annotate("segment", x = 0, xend = 100, y = c(pm, pt)[i_p], yend = c(pm, pt)[i_p],
             colour = couleurs_eco[["equilibre"]], linewidth = 0.6, linetype = c("solid", "22")[i_p]) +
    annotate("segment", x = c(q1, q2, q3, q4)[i_q], xend = c(q1, q2, q3, q4)[i_q], y = 0,
             yend = c(pm, pt, pt, pm)[i_q], linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_line(data = courbes, aes(q, demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(data = courbes, aes(q, offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    annotate("text", x = c(95, 52), y = c(12, 60), label = c("D", "O"),
             colour = couleurs_eco[c("demande", "offre")], family = police_cours, size = taille) +
    # importations sans et avec droit, empilées sous Pw (zone vide du graphique)
    annotate("segment", x = c(q1, q2)[i_p], xend = c(q4, q3)[i_p], y = c(pm - 3, pm - 10)[i_p],
             yend = c(pm - 3, pm - 10)[i_p],
             linewidth = 0.5, colour = couleurs_eco[["neutre"]],
             arrow = grid::arrow(ends = "both", length = grid::unit(0.15, "cm"))) +
    # fond blanc : le texte n'est pas barré par les pointillés de Q₂ et Q₃
    annotate("label", x = (q1 + q4) / 2, y = c(pm - 5.8, pm - 12.8)[i_p],
             label = c("importations sans droit", "importations avec droit")[i_p],
             family = police_cours, size = taille * 0.75, colour = couleurs_eco[["neutre"]],
             fill = "white", linewidth = 0)   # sans bordure (label.size ignoré depuis ggplot2 4.0)
  if (chiffres) {
    g <- g + scale_x_continuous(breaks = c(q1, q2, q3, q4)[i_q], labels = c(q1, q2, q3, q4)[i_q]) +
      scale_y_continuous(breaks = c(pm, pt)[i_p], labels = c("Pw = 20", "Pw + t = 30")[i_p]) +
      labs(x = "Quantité Q (millions de tee-shirts)", y = "Prix P (€)")
  } else {
    g <- g + scale_x_continuous(breaks = c(q1, q2, q3, q4)[i_q], labels = c("Q₁", "Q₂", "Q₃", "Q₄")[i_q]) +
      scale_y_continuous(breaks = c(pm, pt)[i_p], labels = c("Pw", "Pw + t")[i_p]) +
      labs(x = "Quantité Q", y = "Prix P")
  }
  g + coord_cartesian(xlim = c(0, 100), ylim = c(0, 65), expand = FALSE, clip = "off") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 3. Incidence dans un grand pays (Exemple 3 de la page)
#    Même droit t = 10 €, mais les exportateurs étrangers baissent leur prix
#    hors droit de 20 € à 19 € : ils paient 1 € du droit, les acheteurs 9 €.
# ---------------------------------------------------------------------------
baisse_export_cm9 <- 1
part_etranger_cm9 <- 100 * baisse_export_cm9 / tarif_cm9$t           # 10 %
part_interieur_cm9 <- 100 - part_etranger_cm9                        # 90 %
# Bilan du grand pays : prix intérieur 19 + 10 = 29 €, au lieu de 20 € sans droit
p_grand_cm9 <- tarif_cm9$pm - baisse_export_cm9 + tarif_cm9$t                    # 29 €
imports_grand_cm9 <- qd_cm9(p_grand_cm9) - qo_cm9(p_grand_cm9)                    # 71 - 29 = 42 millions
paye_etranger_cm9 <- baisse_export_cm9 * imports_grand_cm9                        # 42 M€
hausse_grand_cm9 <- p_grand_cm9 - tarif_cm9$pm                                    # 9 €
aire_b_grand_cm9 <- (qo_cm9(p_grand_cm9) - qo_cm9(tarif_cm9$pm)) * hausse_grand_cm9 / 2   # 40,5 M€
aire_d_grand_cm9 <- (qd_cm9(tarif_cm9$pm) - qd_cm9(p_grand_cm9)) * hausse_grand_cm9 / 2   # 40,5 M€

# ---------------------------------------------------------------------------
# 4. Graphique de données : recettes douanières américaines, oct. 2024 - sept. 2026
#    Trésor américain, Monthly Treasury Statement, table 4, « Customs Duties »,
#    en Md$ par mois, brut et net des remboursements.
#    Fichier et provenance : data/cm9/recettes_douane_us.csv et data/cm9/SOURCES.md
# ---------------------------------------------------------------------------
recettes_cm9 <- utils::read.csv(here::here("data/cm9/recettes_douane_us.csv"))
recettes_cm9$date <- as.Date(recettes_cm9$date)
# Exercice budgétaire américain : d'octobre (année N-1) à septembre (année N)
recettes_cm9$exercice <- as.integer(format(recettes_cm9$date, "%Y")) +
  (as.integer(format(recettes_cm9$date, "%m")) >= 10)
total_exercice <- function(col, ex) sum(recettes_cm9[[col]][recettes_cm9$exercice == ex])
mois_cm9 <- function(col, jour) recettes_cm9[[col]][recettes_cm9$date == as.Date(jour)]

#' Recettes douanières américaines mensuelles, brutes et nettes des
#' remboursements (Md$). Repères : 2 avril 2025 et 20 février 2026.
graphe_recettes_douane <- function(base_size = 16) {
  # chaque mois est tracé au 1er du mois (le CSV donne le dernier jour),
  # pour qu'un point tombe sur la graduation de son mois
  diapo <- base_size > 16   # diapos : noms, titre d'axe, source et repères plus courts
  debut_mois <- as.Date(format(recettes_cm9$date, "%Y-%m-01"))
  series <- if (diapo) c("Brutes", "Nettes des remboursements") else
    c("Recettes brutes", "Recettes nettes des remboursements")
  d <- rbind(
    data.frame(date = debut_mois, serie = series[1], md = recettes_cm9$brut),
    data.frame(date = debut_mois, serie = series[2], md = recettes_cm9$net)
  )
  # étiquettes de part et d'autre de chaque repère, là où il n'y a pas de données ;
  # en diapo, à des hauteurs distinctes pour qu'elles ne se chevauchent pas
  reperes <- data.frame(date = as.Date(c("2025-04-02", "2026-02-20")), cote = c(1, -1),
                        y = if (diapo) c(-24, 12) else c(-24, -10),
                        lab = if (diapo) c("2 avril 2025", "Arrêt du 20/02/2026") else
                          c("2 avril 2025 :\n« Jour de la libération »", "20 février 2026 :\narrêt de la Cour suprême"))
  ticks <- as.Date(c("2024-10-01", "2025-01-01", "2025-04-01", "2025-07-01", "2025-10-01",
                     "2026-01-01", "2026-04-01", "2026-07-01", "2026-10-01"))
  noms <- c("oct.\n2024", "janv.\n2025", "avr.", "juil.", "oct.", "janv.\n2026", "avr.", "juil.", "oct.")
  if (diapo) noms[c(3, 4, 7, 8)] <- ""   # diapos : moins d'étiquettes
  ggplot(d, aes(date, md, colour = serie)) +
    geom_hline(yintercept = 0, colour = couleurs_eco[["equilibre"]], linewidth = 0.4) +
    geom_vline(data = reperes, aes(xintercept = date), linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_text(data = reperes, aes(x = date + 6 * cote, y = y, label = lab, hjust = (1 - cote) / 2),
              inherit.aes = FALSE, vjust = 0, lineheight = 0.9, family = police_cours,
              size = base_size / 3.6, colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.1) +
    geom_point(size = 1.4) +
    scale_colour_manual(values = ordre_series[1:2]) +
    scale_x_date(breaks = ticks, labels = noms,
                 expand = expansion(mult = c(0.02, 0.1))) +   # marge à droite : la graduation « oct. » 2026 n'est pas rognée
    scale_y_continuous(breaks = seq(-20, 30, 10), labels = function(x) sub("-", "\u2212", x)) +   # vrai signe moins
    coord_cartesian(ylim = c(-27, 35)) +
    labs(x = NULL, y = if (diapo) "Md$ par mois" else "Milliards de dollars par mois",
         caption = if (diapo) "Source : Trésor des États-Unis (21/10/2026)." else
           "Source : Trésor des États-Unis, Monthly Treasury Statement, table 4, « Customs Duties »\n(téléchargé le 21/10/2026).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5. Commerce de biens UE-États-Unis (tableau de la page), Eurostat ext_lt_maineu
# ---------------------------------------------------------------------------
commerce_cm9 <- utils::read.csv(here::here("data/cm9/commerce_ue_usa.csv"))
commerce_cm9$solde <- commerce_cm9$exportations - commerce_cm9$importations

# ---------------------------------------------------------------------------
# 6. Graphique de données : prix hors droit des importations et prix à la
#    consommation des biens aux États-Unis, janv. 2024 - sept. 2026 (BLS).
#    Si les exportateurs étrangers payaient le droit, les prix hors droit des
#    importations baisseraient. Indices ramenés à 100 en janvier 2025.
#    Octobre 2025 manque (pas de collecte pendant la fermeture de l'administration).
#    Fichier et provenance : data/cm9/prix_import_conso_us.csv et data/cm9/SOURCES.md
# ---------------------------------------------------------------------------
prix_cm9 <- utils::read.csv(here::here("data/cm9/prix_import_conso_us.csv"))
prix_cm9$date <- as.Date(prix_cm9$date)
base_cm9 <- prix_cm9$date == as.Date("2025-01-01")
prix_cm9$import_100 <- 100 * prix_cm9$prix_import / prix_cm9$prix_import[base_cm9]
prix_cm9$conso_100  <- 100 * prix_cm9$prix_conso_biens / prix_cm9$prix_conso_biens[base_cm9]
# variation en % d'une colonne entre deux mois (AAAA-MM-01)
variation_cm9 <- function(col, de, a) {
  x <- prix_cm9[[col]]
  100 * (x[prix_cm9$date == as.Date(a)] / x[prix_cm9$date == as.Date(de)] - 1)
}

#' Prix hors droit des importations (hors carburants) et prix à la consommation
#' des biens hors alimentation et énergie, base 100 en janvier 2025.
#' Repère : 2 avril 2025. Le mois manquant (octobre 2025) coupe les courbes.
#' @param base_size 16 (page) ou 24 (diapos)
graphe_prix_import <- function(base_size = 16) {
  diapo <- base_size > 16   # diapos : étiquettes plus courtes
  series <- if (diapo) c("Importations, hors droit", "Biens de consommation") else
    c("Prix des importations, hors droit (hors carburants)",
      "Prix à la consommation des biens (hors alimentation et énergie)")
  d <- rbind(
    data.frame(date = prix_cm9$date, indice = prix_cm9$import_100, serie = series[1]),
    data.frame(date = prix_cm9$date, indice = prix_cm9$conso_100, serie = series[2])
  )
  d$serie <- factor(d$serie, levels = unique(d$serie))
  ticks <- as.Date(c("2024-01-01", "2024-07-01", "2025-01-01", "2025-07-01",
                     "2026-01-01", "2026-07-01"))
  noms <- c("janv.\n2024", "juil.", "janv.\n2025", "juil.", "janv.\n2026", "juil.")
  if (diapo) noms[c(2, 4, 6)] <- ""
  source_txt <- "Source : Bureau of Labor Statistics, séries EIUIREXFUELS et CUSR0000SACL1E\n(téléchargées le 21/10/2026) ; base 100 calculée par l'auteur."
  if (diapo) source_txt <- "Source : Bureau of Labor Statistics (21/10/2026)."
  ggplot(d, aes(date, indice, colour = serie)) +
    geom_hline(yintercept = 100, colour = couleurs_eco[["equilibre"]], linewidth = 0.4) +
    geom_vline(xintercept = as.Date("2025-04-02"), linetype = "22", colour = couleurs_eco[["neutre"]]) +
    annotate("text", x = as.Date("2025-04-02") - 8, y = 105.5, hjust = 1, vjust = 1,
             label = "2 avril 2025 :\n« Jour de la libération »", lineheight = 0.9,
             family = police_cours, size = base_size / 3.6, colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.1, na.rm = TRUE) +
    geom_point(size = 1.3, na.rm = TRUE) +
    scale_colour_manual(values = ordre_series[1:2]) +
    scale_x_date(breaks = ticks, labels = noms) +
    scale_y_continuous(breaks = seq(98, 106, 2), labels = function(x) format(x, decimal.mark = ",")) +
    coord_cartesian(ylim = c(97.5, 106.5)) +
    guides(colour = guide_legend(ncol = if (diapo) 2 else 1)) +
    labs(x = NULL, y = if (diapo) "Base 100 : janv. 2025" else "Indice, base 100 en janvier 2025",
         caption = source_txt) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 7. Vérifications : chaque chiffre annoncé dans cours/cm9.qmd
# ---------------------------------------------------------------------------
# Exemple 1 : avantage comparatif
stopifnot(
  all(ricardo_cm9$h_ble[1] < ricardo_cm9$h_ble[2], ricardo_cm9$h_vet[1] < ricardo_cm9$h_vet[2]),  # A meilleur partout
  proche(ricardo_cm9$co_vet, c(2, 0.5)),                       # coût d'un lot de vêtements : 2 t (A), 0,5 t (B)
  proche(ricardo_cm9$max_ble, c(60, 20)), proche(ricardo_cm9$max_vet, c(30, 40)),
  proche(ricardo_cm9$aut_ble, c(30, 10)), proche(ricardo_cm9$aut_vet, c(15, 20)),
  proche(sum(ricardo_cm9$aut_ble), 40), proche(sum(ricardo_cm9$aut_vet), 35),   # monde en autarcie
  proche(ricardo_cm9$max_ble[1], 60), proche(ricardo_cm9$max_vet[2], 40),       # monde spécialisé : 60 t, 40 lots
  proche(ricardo_cm9$con_ble, c(40, 20)), proche(ricardo_cm9$con_vet, c(20, 20)),
  all(ricardo_cm9$con_ble >= ricardo_cm9$aut_ble), all(ricardo_cm9$con_vet >= ricardo_cm9$aut_vet),
  # le prix d'échange (1 lot = 1 t) est compris entre les deux coûts d'opportunité
  1 < ricardo_cm9$co_vet[1], 1 > ricardo_cm9$co_vet[2]
)
# Exemple 2 : droit de douane, petit pays
stopifnot(
  proche(qd_cm9(20), 80), proche(qo_cm9(20), 20), proche(imports_sans_cm9, 60),
  proche(qd_cm9(30), 70), proche(qo_cm9(30), 30), proche(imports_avec_cm9, 40),
  proche(100 * tarif_cm9$t / tarif_cm9$pm, 50),                       # droit de 50 % du prix mondial
  proche(perte_conso_cm9, 750), proche(aire_a_cm9, 250), proche(aire_c_cm9, 400),
  proche(aire_b_cm9, 50), proche(aire_d_cm9, 50),
  proche(perte_conso_cm9, aire_a_cm9 + aire_b_cm9 + aire_c_cm9 + aire_d_cm9),
  proche(perte_conso_cm9 - aire_a_cm9 - aire_c_cm9, 100),            # perte sèche totale
  proche(qd_cm9(50), qo_cm9(50))                                      # autarcie à 50 € (hors figure)
)
# Exemple 3 : incidence, grand pays
stopifnot(proche(part_etranger_cm9, 10), proche(part_interieur_cm9, 90),
          proche(p_grand_cm9, 29), proche(hausse_grand_cm9, 9),
          proche(qd_cm9(p_grand_cm9), 71), proche(imports_grand_cm9, 42),
          proche(paye_etranger_cm9, 42),                               # 42 M€ payés par l'étranger
          proche(aire_b_grand_cm9, 40.5), proche(aire_d_grand_cm9, 40.5),
          proche(aire_b_grand_cm9 + aire_d_grand_cm9, 81),              # perte sèche
          paye_etranger_cm9 < aire_b_grand_cm9 + aire_d_grand_cm9)       # le pays reste perdant
# Données du Trésor américain (Md$)
stopifnot(
  nrow(recettes_cm9) == 24, !anyNA(recettes_cm9),
  proche(round(total_exercice("brut", 2025), 1), 202.4),
  proche(round(total_exercice("brut", 2026), 1), 317.8),
  proche(round(total_exercice("net", 2025), 1), 194.9),
  proche(round(total_exercice("net", 2026), 1), 173.2),
  proche(round(100 * (total_exercice("brut", 2026) / total_exercice("brut", 2025) - 1)), 57),
  proche(round(total_exercice("brut", 2025) - total_exercice("net", 2025), 1), 7.5),
  proche(round(total_exercice("brut", 2026) - total_exercice("net", 2026)), 145),
  proche(round(mois_cm9("brut", "2024-10-31"), 1), 7.9),
  proche(round(max(recettes_cm9$brut), 1), 33.1), proche(mois_cm9("brut", "2025-10-31"), max(recettes_cm9$brut)),
  proche(round(mois_cm9("brut", "2026-09-30"), 1), 25.3),
  all(recettes_cm9$net[recettes_cm9$date %in% as.Date(c("2026-05-31", "2026-06-30", "2026-07-31"))] < 0),
  proche(round(min(recettes_cm9$net), 1), -25.6)
)
# Données Eurostat (Md€)
stopifnot(
  proche(commerce_cm9$annee, 2023:2025),
  proche(commerce_cm9$exportations, c(505.9, 535.6, 554.7)),   # tableau de la page, 2023-2025
  proche(commerce_cm9$importations, c(347.8, 337.4, 356.7)),
  proche(commerce_cm9$solde, c(158.1, 198.2, 198.0), tol = 1e-6)
)
# Données du BLS (indices de prix)
stopifnot(
  nrow(prix_cm9) == 33, sum(is.na(prix_cm9$prix_import)) == 1,           # seul octobre 2025 manque
  is.na(prix_cm9$prix_import[prix_cm9$date == as.Date("2025-10-01")]),
  proche(prix_cm9$prix_import[base_cm9], 129.8),
  proche(prix_cm9$prix_import[prix_cm9$date == as.Date("2025-09-01")], 129.8),
  proche(round(variation_cm9("prix_import", "2025-01-01", "2025-09-01"), 1), 0),      # 0 % en 2025
  proche(round(variation_cm9("prix_conso_biens", "2025-01-01", "2025-09-01"), 1), 1.0),  # +1,0 %
  proche(round(variation_cm9("prix_conso_biens", "2024-01-01", "2024-09-01"), 1), -0.6), # -0,6 %
  proche(round(variation_cm9("prix_import", "2025-12-01", "2026-09-01"), 1), 5.2),    # +5,2 %
  max(prix_cm9$import_100, na.rm = TRUE) < 106.5, min(prix_cm9$import_100, na.rm = TRUE) > 97.5  # dans l'axe
)
