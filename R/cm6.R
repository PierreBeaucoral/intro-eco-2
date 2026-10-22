# cm6.R · graphiques et chiffres du CM 6 (D'où vient l'argent ? Création
# monétaire, bilan bancaire, paniques bancaires), partagés par la page de cours
# (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Les valeurs des exemples et des figures de cours/cm6.qmd sont définies ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.

proche <- function(x, y, tol = 1e-6) abs(x - y) < tol

# ---------------------------------------------------------------------------
# 1. Exemple 1 : un prêt crée un dépôt (bilan de la banque A, en euros)
#    Trois étapes : avant le prêt, après le prêt de 1 000 € à Léa, après le
#    paiement de Léa au vendeur, client de la banque B.
# ---------------------------------------------------------------------------
bilan_cm6 <- data.frame(
  etape        = c("avant", "pret", "paiement"),
  reserves     = c(2000, 2000, 1000),
  credits      = c(8000, 9000, 9000),
  depots       = c(9000, 10000, 9000),
  fonds_propres = c(1000, 1000, 1000)
)
pret_lea_cm6 <- 1000

#' Diapos seulement : le bilan de la banque A de l'exemple 1 en deux colonnes
#' empilées (actif, passif), une étape par appel : 1 = avant le prêt ; 2 = après
#' le prêt de 1 000 € à Léa ; 3 = après le paiement au vendeur (banque B).
graphe_bilan <- function(base_size = 16, etape = 3) {
  b <- bilan_cm6[etape, ]
  postes <- c(reserves = "Réserves", credits = "Crédits", fonds_propres = "Fonds propres", depots = "Dépôts")
  d <- data.frame(
    cote = factor(c("Actif", "Actif", "Passif", "Passif"), levels = c("Actif", "Passif")),
    poste = factor(unname(postes), levels = unname(postes)),
    montant = unlist(b[names(postes)])
  )
  millier <- function(x) format(x, big.mark = " ", trim = TRUE)
  d$etiquette <- paste(d$poste, millier(d$montant))
  totaux <- data.frame(cote = factor(c("Actif", "Passif"), levels = c("Actif", "Passif")),
                       total = c(b$reserves + b$credits, b$depots + b$fonds_propres))
  taille <- base_size / 3.6
  ggplot(d, aes(cote, montant, fill = poste, group = poste)) +
    geom_col(width = 0.9, colour = "#FFFFFF", linewidth = 0.8, position = position_stack(reverse = TRUE)) +
    geom_text(aes(label = etiquette), position = position_stack(vjust = 0.5, reverse = TRUE),
              colour = "#FFFFFF", family = police_cours, size = taille * 0.62) +
    geom_text(data = totaux, aes(cote, total, label = paste("Total", millier(total))), inherit.aes = FALSE,
              vjust = -0.5, family = police_cours, size = taille, colour = couleurs_eco[["equilibre"]]) +
    scale_fill_manual(values = c(`Réserves` = couleurs_eco[["offre"]], `Crédits` = couleurs_eco[["demande"]],
                                 `Dépôts` = couleurs_eco[["demande"]], `Fonds propres` = couleurs_eco[["neutre"]])) +
    scale_y_continuous(limits = c(0, 12500), breaks = c(0, 5000, 10000), labels = millier) +
    labs(x = NULL, y = "Montant (€)") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 2. Exemple 2 : une panique bancaire à la Diamond et Dybvig (nombres ronds)
#    100 déposants de 100 € ; réserves 1 000 €, prêts 9 000 € remboursés dans
#    un an avec 10 % d'intérêts. Contrat : 100 € tout de suite, ou 110 € dans
#    un an. 10 déposants ont toujours besoin de leur argent tout de suite.
#    Vendus en urgence, les prêts ne rapportent que la moitié de leur montant.
# ---------------------------------------------------------------------------
panique_cm6 <- list(
  deposants = 100, depot = 100, reserves = 1000, prets = 9000,
  interet = 0.10, decote = 0.5, impatients = 10, promesse_attente = 110
)

#' Ce que la banque peut verser tout de suite au maximum (réserves + prêts
#' vendus en urgence).
liquidite_max <- function(p = panique_cm6) p$reserves + p$prets * p$decote

#' Somme reçue par un déposant qui retire tout de suite quand N déposants
#' retirent : 100 € tant que la banque peut payer, puis la moyenne de ce
#' qu'elle peut verser (les premiers servis ont 100 €, les derniers rien).
gain_retirer <- function(n, p = panique_cm6) {
  ifelse(n * p$depot <= liquidite_max(p), p$depot, liquidite_max(p) / n)
}

#' Somme reçue dans un an par un déposant qui attend quand N déposants
#' retirent tout de suite (N >= 10, nombre des impatients). Au-delà des
#' réserves, la banque vend des prêts à moitié prix ; ce qui reste des prêts,
#' intérêts compris, est partagé entre ceux qui ont attendu.
gain_attendre <- function(n, p = panique_cm6) {
  manque <- pmax(n * p$depot - p$reserves, 0)              # à trouver en vendant des prêts
  prets_restants <- pmax(p$prets - manque / p$decote, 0)    # montant de prêts encore détenus
  reste_reserves <- pmax(p$reserves - n * p$depot, 0)
  total <- prets_restants * (1 + p$interet) + reste_reserves
  ifelse(n >= p$deposants, NA_real_, total / (p$deposants - n))
}

#' Seuil de retraits au-delà duquel attendre rapporte moins que retirer :
#' (12 100 − 220 N) / (100 − N) = 100, soit N = 17,5.
seuil_panique_cm6 <- with(panique_cm6, {
  a <- (prets + reserves / decote) * (1 + interet)          # 12 100
  b <- depot / decote * (1 + interet)                       # 220
  (a - depot * deposants) / (b - depot)                     # 17,5
})

#' Graphique de l'exemple 2 : ce que reçoit un déposant selon qu'il retire
#' tout de suite ou qu'il attend, en fonction du nombre de déposants qui
#' retirent. Deux équilibres : calme (10 retraits) et panique (100 retraits).
#' Graduations chiffrées assumées : la figure illustre l'exemple chiffré.
#' @param etape construction pas à pas pour les diapos : 1 = « retirer » seule,
#'   avec la banque vide à 55 ; 2 = ajoute « attendre » et l'équilibre calme ;
#'   3 = ajoute le seuil ≈ 18 ; 4 = figure complète (panique), identique à la page
graphe_panique <- function(base_size = 16, etape = 4) {
  n <- seq(panique_cm6$impatients, panique_cm6$deposants, by = 0.5)
  d <- rbind(
    data.frame(n = n, serie = "retirer", gain = gain_retirer(n)),
    data.frame(n = n, serie = "attendre", gain = gain_attendre(n))
  )
  d <- d[!is.na(d$gain), ]
  if (etape < 2) d <- d[d$serie == "retirer", ]
  taille <- base_size / 3
  vide <- liquidite_max() / panique_cm6$depot                # 55 : la banque est vide
  i_pt <- if (etape >= 4) 1:2 else if (etape >= 2) 1 else integer(0)   # calme, puis panique
  i_ser <- if (etape >= 2) 1:2 else 1                                   # retirer, puis attendre
  ggplot(d, aes(n, gain, colour = serie)) +
    (if (etape >= 3) annotate("segment", x = seuil_panique_cm6, xend = seuil_panique_cm6, y = 0, yend = 108,
             linetype = "22", colour = couleurs_eco[["neutre"]])) +
    annotate("segment", x = vide, xend = vide, y = 0, yend = 118,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    (if (etape >= 3) annotate("text", x = seuil_panique_cm6 + 1, y = 6, label = "seuil ≈ 18",
             hjust = 0, family = police_cours, size = taille * 0.85, colour = couleurs_eco[["neutre"]])) +
    annotate("text", x = vide + 1, y = 122, label = "banque vide (55)",
             hjust = 0, family = police_cours, size = taille * 0.85, colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.4) +
    (if (etape >= 2) annotate("point", x = c(10, 100)[i_pt], y = c(gain_attendre(10), gain_retirer(100))[i_pt], size = 3,
             colour = couleurs_eco[["equilibre"]])) +
    (if (etape >= 2) annotate("text", x = 12, y = 116, label = "équilibre calme", hjust = 0,   # près du point (10 ; 110)
             family = police_cours, size = taille * 0.85)) +
    (if (etape >= 4) annotate("text", x = 99, y = 46, label = "panique", hjust = 1,
             family = police_cours, size = taille * 0.85)) +
    annotate("text", x = c(58, 21)[i_ser], y = c(108, 25)[i_ser], label = c("retirer tout de suite", "attendre un an")[i_ser],
             colour = unname(couleurs_eco[c("alerte", "demande")])[i_ser], hjust = 0,
             family = police_cours, size = taille) +
    scale_colour_manual(values = c(retirer = couleurs_eco[["alerte"]], attendre = couleurs_eco[["demande"]])) +
    scale_x_continuous(breaks = c(10, 30, 55, 100)) +
    scale_y_continuous(breaks = c(0, 55, 100, 110)) +
    coord_cartesian(xlim = c(8, 102), ylim = c(0, 125), expand = FALSE, clip = "off") +
    labs(x = "Nombre de déposants qui retirent tout de suite", y = "Somme reçue par déposant (€)") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 3. Données : SVB et grandes banques américaines, fin 2022
#    Réserve fédérale, rapport du 28/04/2023, Table 1 « Peer comparison,
#    2022:Q4 ». Fichier et provenance : data/cm6/svb_table1.csv, data/cm6/SOURCES.md.
# ---------------------------------------------------------------------------
svb_cm6 <- utils::read.csv(here::here("data/cm6/svb_table1.csv"), check.names = FALSE)

#' Barres horizontales : SVB face aux grandes banques américaines (2022 T4).
#' @param etape construction pas à pas pour les diapos : 1 = composition de
#'   l'actif (prêts, titres ; les quatre lignes restent en place) ; 2 = figure complète
graphe_svb <- function(base_size = 16, etape = 2) {
  d <- rbind(
    data.frame(indicateur = svb_cm6$indicateur, banque = "SVB", valeur = svb_cm6$svb),
    data.frame(indicateur = svb_cm6$indicateur, banque = "Grandes banques américaines (moyenne)",
               valeur = svb_cm6$grandes_banques)
  )
  # étiquettes courtes sur deux lignes, dans l'ordre des lignes du fichier
  courtes <- c("Prêts\n(% de l’actif)", "Titres\n(% de l’actif)",
               "Titres détenus jusqu’à\nl’échéance (% des titres)", "Dépôts non assurés\n(% des dépôts)")
  d$indicateur <- factor(courtes[match(d$indicateur, svb_cm6$indicateur)], levels = rev(courtes))
  d$banque <- factor(d$banque, levels = c("SVB", "Grandes banques américaines (moyenne)"),
                     labels = c("SVB", "Grandes banques (moyenne)"))   # libellé court : la légende tient
  if (etape < 2) d <- d[d$indicateur %in% courtes[1:2], ]
  ggplot(d, aes(valeur, indicateur, fill = banque)) +
    (if (etape < 2) scale_y_discrete(drop = FALSE)) +
    geom_col(position = position_dodge(width = 0.75), width = 0.7) +
    geom_text(aes(label = paste0(valeur, " %")), position = position_dodge(width = 0.75),
              hjust = -0.15, family = police_cours, size = base_size / 3.4, colour = couleurs_eco[["equilibre"]]) +
    scale_fill_manual(values = unname(couleurs_eco[c("alerte", "neutre")])) +
    scale_x_continuous(limits = c(0, 110), breaks = c(0, 25, 50, 75, 100)) +
    labs(x = "En %", y = NULL,
         caption = "Source : Réserve fédérale (28/04/2023), Table 1.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(axis.text.y = element_text(size = rel(if (base_size > 16) 0.7 else 0.9), lineheight = 0.9),
          panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          axis.line.x = element_blank(), axis.line.y = element_blank(),
          plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 4. Données : croissance de M3 et des crédits, zone euro, 2019-2026
#    BCE, Data Portal, taux de croissance annuels, données mensuelles
#    (dernier point : août 2026, provisoire). Fichier : data/cm6/m3_credits_zone_euro.csv.
# ---------------------------------------------------------------------------
m3_cm6 <- utils::read.csv(here::here("data/cm6/m3_credits_zone_euro.csv"))
m3_cm6$date <- as.Date(paste0(m3_cm6$mois, "-01"))

#' Valeur d'une série de m3_cm6 pour un mois « AAAA-MM »
valeur_mois <- function(serie, mois) m3_cm6[[serie]][m3_cm6$mois == mois]

#' Lignes : croissance sur un an de M3, des crédits aux ménages et des crédits
#' aux entreprises (sociétés non financières), zone euro, janvier 2019 - août 2026.
#' @param etape construction pas à pas pour les diapos : 1 = M3 seule ;
#'   2 = ajoute les deux séries de crédits ; 3 = figure complète (hausse des taux
#'   de juillet 2022), identique à la page
graphe_m3_credits <- function(base_size = 16, etape = 3) {
  noms <- c(m3 = "Monnaie (M3)", credits_snf = "Crédits aux entreprises",
            credits_menages = "Crédits aux ménages")
  d <- do.call(rbind, lapply(names(noms), function(s)
    data.frame(date = m3_cm6$date, serie = noms[[s]], valeur = m3_cm6[[s]])))
  d$serie <- factor(d$serie, levels = unname(noms))
  if (etape < 2) d <- d[d$serie == noms[["m3"]], ]
  ggplot(d, aes(date, valeur, colour = serie)) +
    geom_hline(yintercept = 0, colour = couleurs_eco[["equilibre"]], linewidth = 0.4) +
    (if (etape >= 3) annotate("segment", x = as.Date("2022-07-27"), xend = as.Date("2022-07-27"), y = -2, yend = 13,
             linetype = "22", colour = couleurs_eco[["neutre"]])) +
    (if (etape >= 3) annotate("text", x = as.Date("2022-09-01"), y = 13, label = "juillet 2022 : la BCE\ncommence à relever ses taux",
             hjust = 0, vjust = 1, lineheight = 0.9, family = police_cours, size = base_size / 3.6,
             colour = couleurs_eco[["neutre"]])) +
    geom_line(linewidth = 1.1) +
    scale_colour_manual(values = unname(couleurs_eco[c("equilibre", "demande", "offre")])) +
    scale_x_date(breaks = as.Date(paste0(2019:2026, "-01-01")), labels = as.character(2019:2026)) +
    scale_y_continuous(breaks = seq(0, 12, 4), labels = function(x) paste0(x, " %")) +
    coord_cartesian(ylim = c(-2, 13)) +
    labs(x = NULL, y = "Croissance sur un an",
         caption = "Source : BCE, Data Portal, séries BSI (consulté le 21/10/2026) ; août 2026 provisoire.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption = element_text(margin = margin(t = 10))) +
    guides(colour = guide_legend(nrow = if (base_size > 16) 2 else 1))
}

# Encours d'août 2026 (Md€, données corrigées des variations saisonnières)
encours_cm6 <- utils::read.csv(here::here("data/cm6/encours_aout2026.csv"))
encours <- function(agregat) encours_cm6$encours_md_eur[encours_cm6$agregat == agregat]
part_billets_m3 <- 100 * encours("billets_pieces") / encours("m3")

# Composition de M3 en août 2026, calculée par différence entre agrégats
# emboîtés (M1 ⊂ M2 ⊂ M3), en Md€ et en % de M3.
composition_m3_cm6 <- data.frame(
  composante = c("Billets et pièces", "Dépôts à vue",
                 "Livrets et dépôts\nà terme courts",
                 "Autres placements\n(fonds monétaires…)"),
  md_eur = c(encours("billets_pieces"), encours("m1") - encours("billets_pieces"),
             encours("m2") - encours("m1"), encours("m3") - encours("m2"))
)
composition_m3_cm6$part <- 100 * composition_m3_cm6$md_eur / encours("m3")

#' Barres horizontales : les quatre composantes de M3, zone euro, août 2026.
#' Les billets et pièces (ambre) se détachent des formes bancaires (azur).
#' @param etape construction pas à pas pour les diapos : 1 = M1 seule (billets
#'   et dépôts à vue, les quatre lignes restent en place) ; 2 = figure complète
graphe_composition_m3 <- function(base_size = 16, etape = 2) {
  d <- composition_m3_cm6
  d$composante <- factor(d$composante, levels = rev(d$composante))   # billets en haut
  d$billets <- d$composante == "Billets et pièces"
  d$etiquette <- paste0(format(d$md_eur, big.mark = " ", trim = TRUE), " Md€ (", round(d$part), " %)")
  if (etape < 2) d <- d[1:2, ]                                       # M1 = deux premières lignes
  ggplot(d, aes(md_eur, composante, fill = billets)) +
    (if (etape < 2) scale_y_discrete(drop = FALSE)) +
    geom_col(width = 0.65) +
    geom_text(aes(label = etiquette), hjust = -0.08, family = police_cours,
              size = base_size / 3.4, colour = couleurs_eco[["equilibre"]]) +
    scale_fill_manual(values = c(`TRUE` = couleurs_eco[["offre"]], `FALSE` = couleurs_eco[["demande"]])) +
    scale_x_continuous(limits = c(0, 15500), breaks = seq(0, 10000, 5000),
                       labels = function(x) format(x, big.mark = " ", trim = TRUE)) +
    labs(x = "Encours (Md€)", y = NULL,
         caption = "Source : BCE, Data Portal (consulté le 21/10/2026).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none",
          axis.text.y = element_text(size = rel(if (base_size > 16) 0.7 else 0.85), lineheight = 0.9, hjust = 1),
          panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          axis.line.x = element_blank(),
          plot.caption.position = "plot",
          plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5. Vérifications : chaque chiffre annoncé dans cours/cm6.qmd
# ---------------------------------------------------------------------------
# Exemple 1 : le bilan est équilibré à chaque étape ; le prêt crée 1 000 € de
# dépôts sans qu'aucun autre dépôt baisse ; le paiement transfère 1 000 € de réserves.
stopifnot(
  with(bilan_cm6, all(reserves + credits == depots + fonds_propres)),
  with(bilan_cm6, depots[2] - depots[1] == pret_lea_cm6 && credits[2] - credits[1] == pret_lea_cm6),
  with(bilan_cm6, reserves[2] == reserves[1] && reserves[2] - reserves[3] == pret_lea_cm6),
  with(bilan_cm6, depots[3] == depots[1])
)
# Exemple 2 : panique bancaire
stopifnot(
  with(panique_cm6, reserves + prets == deposants * depot),               # bilan : 10 000 €
  with(panique_cm6, impatients * depot == reserves),                       # temps calme : réserves suffisent
  proche(gain_attendre(10), 110),                                          # 9 900 / 90
  proche(panique_cm6$prets * (1 + panique_cm6$interet), 9900),
  proche(liquidite_max(), 5500),                                           # 1 000 + 4 500
  proche(liquidite_max() / panique_cm6$depot, 55),                         # 55 premiers servis
  proche(gain_attendre(30), 5500 / 70), proche(round(gain_attendre(30)), 79),
  proche(gain_attendre(20), 96.25),
  proche(gain_retirer(100), 55),
  proche(gain_attendre(55), 0),
  proche(seuil_panique_cm6, 17.5),
  gain_attendre(18) < gain_retirer(18), gain_attendre(17) > gain_retirer(17)
)
# SVB (Fed, 28/04/2023) : Table 1
stopifnot(
  nrow(svb_cm6) == 4,
  identical(as.numeric(svb_cm6$svb), c(35, 55, 78, 94)),
  identical(as.numeric(svb_cm6$grandes_banques), c(58, 25, 42, 41))
)
# BCE : chiffres de M3 et des crédits cités dans le texte
stopifnot(
  nrow(m3_cm6) == 92, !anyNA(m3_cm6),
  proche(round(max(m3_cm6$m3), 1), 12.5), proche(valeur_mois("m3", "2021-01"), max(m3_cm6$m3)),
  proche(round(min(m3_cm6$m3), 1), -1.3), proche(valeur_mois("m3", "2023-08"), min(m3_cm6$m3)),
  proche(round(valeur_mois("m3", "2026-08"), 1), 3.5),
  proche(round(valeur_mois("credits_snf", "2022-09"), 1), 8.9),
  proche(valeur_mois("credits_snf", "2022-09"), max(m3_cm6$credits_snf)),
  valeur_mois("credits_snf", "2023-10") < 0,
  proche(round(valeur_mois("credits_menages", "2026-08"), 1), 3.1),
  proche(round(valeur_mois("credits_snf", "2026-08"), 1), 4.2),
  proche(round(min(m3_cm6$credits_menages), 1), 0.2)
)
# Encours d'août 2026 : 17 646 Md€ de M3, dont 1 617 Md€ de billets et pièces (≈ 9 %)
stopifnot(encours("m3") == 17646, encours("billets_pieces") == 1617, encours("m1") == 11293,
          proche(round(part_billets_m3), 9))
# Composition de M3 (figure fig-composition-m3) : 1 617 / 9 676 / 5 154 / 1 199 Md€,
# soit 9 / 55 / 29 / 7 % ; dépôts à vue et épargne à court terme : 84 % de M3.
stopifnot(encours("m2") == 16447,
          identical(as.numeric(composition_m3_cm6$md_eur), c(1617, 9676, 5154, 1199)),
          sum(composition_m3_cm6$md_eur) == encours("m3"),
          identical(round(composition_m3_cm6$part), c(9, 55, 29, 7)),
          proche(round(sum(composition_m3_cm6$part[2:3])), 84),
          proche(round(composition_m3_cm6$md_eur[2] / composition_m3_cm6$md_eur[1]), 6))   # fig-alt : « six fois »
# M3 négative de juillet à novembre 2023 (fig-alt) ; portefeuille de SVB :
# 91 Md$ à l'achat, 76 Md$ sur le marché fin 2022 (Pichet, 13/03/2023), soit ≈ −16 %
stopifnot(all(m3_cm6$m3[m3_cm6$mois %in% sprintf("2023-%02d", 7:11)] < 0),
          valeur_mois("m3", "2023-12") > 0, valeur_mois("m3", "2023-06") > 0,
          proche(round(100 * (76 - 91) / 91), -16))
