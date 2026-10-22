# cm8.R · graphiques du CM 8 (la Grèce, 2010-2015 : l'austérité a-t-elle marché ?),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm8.qmd sont calculées ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.
# Notation du cours : k multiplicateur, c propension marginale à consommer,
# d dette publique / PIB, s solde primaire / PIB, r taux réel, g croissance du PIB.

# ---------------------------------------------------------------------------
# 1. Outils de calcul
# ---------------------------------------------------------------------------

#' Multiplicateur keynésien simple : k = 1 / (1 - c)
#' @param c propension marginale à consommer, entre 0 et 1
multiplicateur <- function(c) 1 / (1 - c)

#' Vagues successives du multiplicateur après une variation de dépense publique
#' @param dG variation initiale de la dépense publique (Md€, positive = baisse étudiée)
#' @param c propension marginale à consommer
#' @param n nombre de vagues
#' @return data.frame (vague, ajout, cumul) : vague 1 = dG, vague 2 = c × dG, etc.
vagues_multiplicateur <- function(dG = 10, c = 0.5, n = 6) {
  ajout <- dG * c^(seq_len(n) - 1)
  data.frame(vague = seq_len(n), ajout = ajout, cumul = cumsum(ajout))
}

#' Trajectoire du ratio dette / PIB, approximation d(t+1) = d(t) + (r - g) × d(t) - s
#' @param d0 ratio de départ (% du PIB)
#' @param r_moins_g écart r - g (en points de %)
#' @param s solde primaire (% du PIB, positif = excédent)
#' @param n nombre d'années
trajectoire_dette <- function(d0 = 150, r_moins_g = 4, s = 0, n = 10) {
  d <- numeric(n + 1)   # pré-alloué
  d[1] <- d0
  for (t in seq_len(n)) d[t + 1] <- d[t] + r_moins_g / 100 * d[t] - s
  data.frame(annee = 0:n, d = d)
}

#' Effet boule de neige sur un an, en points de PIB : (r - g) × d
effet_boule_de_neige <- function(d, r_moins_g) r_moins_g / 100 * d

#' Ratio dette / PIB (%) juste après une baisse de dépense publique.
#' Hypothèse simplificatrice : la dette baisse du montant de la coupe ;
#' le PIB baisse de k × coupe (les pertes de recettes fiscales sont ignorées).
ratio_apres_coupe <- function(k, dette = coupe_cm8$dette, pib = coupe_cm8$pib, coupe = coupe_cm8$coupe) {
  100 * (dette - coupe) / (pib - k * coupe)
}

# Exemple chiffré 1 : coupe de 10 Md€, c = 0,5
vagues_cm8 <- vagues_multiplicateur(dG = 10, c = 0.5, n = 6)

# Exemple chiffré 3 : dette de 300 Md€, PIB de 200 Md€ (d = 150 %), coupe de 10 Md€
coupe_cm8 <- list(dette = 300, pib = 200, coupe = 10)
seuil_k_cm8 <- coupe_cm8$pib / coupe_cm8$dette   # la coupe fait baisser d si k × d < 1, soit k < 1 / d

# ---------------------------------------------------------------------------
# 2. Graphique théorique : les vagues du multiplicateur
# ---------------------------------------------------------------------------

#' Baisse cumulée du PIB, vague après vague, après une coupe de 10 Md€ (c = 0,5).
#' Le total tend vers k × 10 = 20 Md€ (tirets).
#' @param etape construction pas à pas pour les diapos : 1 = première vague seule ;
#'   2 = trois vagues ; 3 = six vagues et limite k × 10, identique à la page (défaut)
graphe_multiplicateur <- function(base_size = 16, etape = 3) {
  v <- vagues_cm8
  if (etape < 3) v <- v[v$vague <= c(1, 3)[etape], ]   # axe des vagues inchangé (drop = FALSE)
  niveaux <- vagues_cm8$vague
  total <- multiplicateur(0.5) * 10
  taille <- base_size / 3
  g <- ggplot(v, aes(factor(vague, levels = niveaux), cumul)) +
    geom_col(fill = couleurs_eco[["demande"]], width = 0.65) +
    geom_text(aes(label = format(round(cumul, 1), decimal.mark = ",")), vjust = 1.6,   # dans la barre, sous les tirets
              family = police_cours, size = taille * 0.85, colour = "#FFFFFF")
  if (etape < 3) g <- g + scale_x_discrete(drop = FALSE)
  if (etape >= 3) g <- g +
    annotate("segment", x = 0.5, xend = 6.5, y = total, yend = total,
             linetype = "22", colour = couleurs_eco[["alerte"]], linewidth = 0.8) +
    annotate("text", x = 0.6, y = total + 1.6, label = "k × 10 = 20 Md€", hjust = 0,
             family = police_cours, size = taille, colour = couleurs_eco[["alerte"]])
  g +
    scale_y_continuous(breaks = c(0, 10, 20), labels = c("0", "10", "20")) +
    coord_cartesian(ylim = c(0, 24), clip = "off") +
    labs(x = "Vague de dépense", y = "Baisse cumulée du PIB (Md€)") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 3. Graphique théorique : l'effet boule de neige
# ---------------------------------------------------------------------------

#' Trois trajectoires du ratio dette / PIB sur dix ans, toutes parties de 150 % :
#' r - g = +4 sans excédent primaire (boule de neige), r - g = +4 avec un excédent
#' primaire de 6 % (le solde stabilisant), r - g = -2 sans excédent (la dette fond).
#' @param etape construction pas à pas pour les diapos : 1 = boule de neige seule (rouge) ;
#'   2 = ajoute le solde stabilisant (gris) ; 3 = les trois trajectoires, identique à la page (défaut)
graphe_boule_de_neige <- function(base_size = 16, etape = 3) {
  scen <- c("r − g = +4, s = 0", "r − g = +4, s = 6", "r − g = −2, s = 0")
  d <- rbind(
    cbind(trajectoire_dette(150, 4, 0), scenario = scen[1]),
    cbind(trajectoire_dette(150, 4, 6), scenario = scen[2]),
    cbind(trajectoire_dette(150, -2, 0), scenario = scen[3])
  )
  d$scenario <- factor(d$scenario, levels = scen)
  if (etape < 3) d <- d[as.integer(d$scenario) <= etape, ]   # couleurs gardées : on retire les derniers scénarios
  fin <- d[d$annee == 10, ]
  cols <- unname(couleurs_eco[c("alerte", "neutre", "demande")])
  ggplot(d, aes(annee, d, colour = scenario)) +
    geom_line(linewidth = 1.3) +
    geom_text(data = fin, aes(label = scenario), hjust = 0, nudge_x = 0.25,
              family = police_cours, size = base_size / 3.4) +
    scale_colour_manual(values = cols) +
    scale_x_continuous(breaks = c(0, 5, 10)) +
    scale_y_continuous(breaks = c(100, 150, 200), limits = c(100, 230)) +
    coord_cartesian(xlim = c(0, 10), clip = "off") +
    labs(x = "Années", y = "Dette publique d (% du PIB)") +
    theme_cours(base_size = base_size) +
    theme(plot.margin = margin(10, if (base_size > 16) 190 else 125, 8, 8))
}

# ---------------------------------------------------------------------------
# 4. Graphique théorique : couper la dépense fait-il baisser le ratio ?
# ---------------------------------------------------------------------------

#' Ratio dette / PIB juste après une coupe de 10 Md€ (dette 300, PIB 200),
#' selon le multiplicateur k. Au-dessus de k = 1 / d = 0,67, le ratio monte.
#' @param etape construction pas à pas pour les diapos : 1 = courbe et ratio de départ ;
#'   2 = ajoute le point de la prévision (k = 0,5) ; 3 = ajoute k = 1,5 et le seuil 0,67,
#'   identique à la page (défaut)
graphe_ratio_coupe <- function(base_size = 16, etape = 3) {
  k <- seq(0, 2, length.out = 81)
  d <- data.frame(k = k, ratio = ratio_apres_coupe(k))
  pts <- data.frame(k = c(0.5, 1.5), ratio = ratio_apres_coupe(k = c(0.5, 1.5)))
  taille <- base_size / 3
  neutre <- couleurs_eco[["neutre"]]
  i_pt <- seq_len(max(etape - 1, 0))           # aucun point, prévision, puis prévision et réalité
  g <- ggplot(d, aes(k, ratio)) +
    annotate("segment", x = 0, xend = 2, y = 150, yend = 150, linetype = "22", colour = neutre)
  if (etape >= 3) g <- g +
    annotate("segment", x = seuil_k_cm8, xend = seuil_k_cm8, y = 144, yend = 150,
             linetype = "22", colour = neutre)
  g <- g + geom_line(colour = couleurs_eco[["alerte"]], linewidth = 1.4)
  if (etape >= 2) g <- g +
    geom_point(data = pts[i_pt, ], size = 3, colour = couleurs_eco[["equilibre"]]) +
    annotate("text", x = c(0.56, 1.44)[i_pt], y = pts$ratio[i_pt] + c(-1.2, 1.2)[i_pt], hjust = c(0, 1)[i_pt],
             label = c("prévision (k = 0,5)", "réalité ? (k = 1,5)")[i_pt],
             family = police_cours, size = taille * 0.9)
  g +
    annotate("text", x = 2, y = 150.9, label = "ratio de départ : 150 %", hjust = 1,
             family = police_cours, size = taille * 0.85, colour = neutre) +
    scale_x_continuous(breaks = c(0, 0.5, seuil_k_cm8, 1, 1.5, 2)[c(1:2, if (etape >= 3) 3, 4:6)],   # 0,67 avec le seuil
                       labels = c("0", "0,5", "0,67", "1", "1,5", "2")[c(1:2, if (etape >= 3) 3, 4:6)]) +
    scale_y_continuous(breaks = c(145, 150, 155, 160)) +
    coord_cartesian(xlim = c(0, 2), ylim = c(144, 162), expand = FALSE, clip = "off") +
    labs(x = "Multiplicateur k", y = "Dette / PIB après la coupe (%)") +
    theme_cours(base_size = base_size)
}

# ---------------------------------------------------------------------------
# 5. Données : la Grèce, 2008-2025 (Eurostat, téléchargé le 21/10/2026)
#    Fichier et provenance : data/cm8/grece_2008_2025.csv et data/cm8/SOURCES.md
# ---------------------------------------------------------------------------
grece_cm8 <- utils::read.csv(here::here("data/cm8/grece_2008_2025.csv"))
repartition_cm8 <- utils::read.csv(here::here("data/cm8/grece_chomage_repartition.csv"))

#' Valeur d'une colonne du fichier Grèce pour une année
gr <- function(col, an) grece_cm8[[col]][grece_cm8$annee == an]

#' Dette publique en Md€ courants : ratio × PIB en valeur
dette_md <- function(an) gr("dette", an) / 100 * gr("pib_valeur", an)

#' Variation en pourcentage
var_pct <- function(x0, x1) 100 * (x1 - x0) / x0

#' Décomposition de la variation du ratio dette / PIB une année donnée.
#' Taux apparent i = intérêts versés / dette de l'année précédente ;
#' croissance du PIB en valeur ; solde primaire = solde public + intérêts.
decomposition_dette <- function(an) {
  i <- 100 * gr("interets", an) * gr("pib_valeur", an) / 100 / dette_md(an - 1)   # intérêts en Md€ / dette en Md€, en %
  croissance <- var_pct(gr("pib_valeur", an - 1), gr("pib_valeur", an))
  s <- gr("solde", an) + gr("interets", an)
  boule <- effet_boule_de_neige(gr("dette", an - 1), i - croissance)
  list(i = i, croissance = croissance, ecart = i - croissance, boule = boule, s = s,
       prevu = boule - s, observe = gr("dette", an) - gr("dette", an - 1))
}
dec_2011 <- decomposition_dette(2011)
dec_2023 <- decomposition_dette(2023)

# Montants prêtés à la Grèce (MES, page « Greece », consultée le 21/10/2026), Md€
plans_cm8 <- c(pays_zone_euro = 52.9, fesf = 141.8, fmi = 32.1, mes = 61.9)

# Reprise 2018-2024 : hausse totale du PIB réel (%) et rythme annuel moyen (%)
reprise_cm8 <- list(totale = var_pct(gr("pib_reel", 2018), gr("pib_reel", 2024)),
                    par_an = 100 * ((gr("pib_reel", 2024) / gr("pib_reel", 2018))^(1 / 6) - 1))

#' Trois panneaux : PIB réel (indice 100 en 2008), chômage (% des actifs, 15-74 ans),
#' dette publique (% du PIB), 2008-2025 ; bande grise = plans d'aide 2010-2018.
#' @param etape pour les diapos : 1, 2 ou 3 = un seul panneau (PIB, chômage, dette),
#'   lisible en deux colonnes ; 4 = les trois panneaux, identique à la page (défaut)
graphe_grece <- function(base_size = 16, etape = 4) {
  panneaux <- c("PIB réel (indice 100 en 2008)", "Chômage (% des actifs)", "Dette publique (% du PIB)")
  d <- rbind(
    data.frame(annee = grece_cm8$annee, panneau = panneaux[1],
               valeur = 100 * grece_cm8$pib_reel / gr("pib_reel", 2008)),
    data.frame(annee = grece_cm8$annee, panneau = panneaux[2], valeur = grece_cm8$chomage),
    data.frame(annee = grece_cm8$annee, panneau = panneaux[3], valeur = grece_cm8$dette)
  )
  d <- d[!is.na(d$valeur), ]
  d$panneau <- factor(d$panneau, levels = panneaux)
  cols <- unname(couleurs_eco[c("demande", "alerte", "offre")])
  legende <- "Bande grise : plans d'aide, 2010-2018. Source : Eurostat (nama_10_gdp, une_rt_a, gov_10dd_edpt1),\nséries téléchargées le 21/10/2026 ; 2024 et 2025 provisoires pour le PIB."
  if (etape <= 3) {                            # un panneau, avec sa couleur de la page
    d <- d[d$panneau == panneaux[etape], ]
    cols <- cols[etape]
    # légende courte, propre au panneau : la légende à trois séries déborde d'un panneau seul
    legende <- paste0("Bande grise : plans d'aide, 2010-2018.\nSource : Eurostat (",
                      c("nama_10_gdp", "une_rt_a", "gov_10dd_edpt1")[etape],
                      "), téléchargée le 21/10/2026",
                      c(" ;\n2024 et 2025 provisoires.", ".", ".")[etape])
  }
  ggplot(d, aes(annee, valeur, colour = panneau)) +
    annotate("rect", xmin = 2010, xmax = 2018, ymin = -Inf, ymax = Inf,
             fill = "#E5E7EB", alpha = 0.6) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 1.4) +
    facet_wrap(~panneau, nrow = 1, scales = "free_y") +
    scale_colour_manual(values = cols) +
    scale_x_continuous(breaks = c(2008, 2013, 2018, 2025)) +
    labs(x = NULL, y = NULL,
         caption = legende) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none",
          strip.text = element_text(family = police_cours, hjust = 0, size = rel(0.75)),
          axis.text = element_text(size = rel(0.8)),
          panel.spacing = grid::unit(1.2, "lines"),
          plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 5 bis. Données : taux à dix ans et chômage par groupe (Eurostat, 21/10/2026)
#    Fichiers : data/cm8/taux_longs_2008_2025.csv, grece_chomage_repartition.csv
# ---------------------------------------------------------------------------
taux_cm8 <- utils::read.csv(here::here("data/cm8/taux_longs_2008_2025.csv"))

#' Taux d'un pays (colonne "grece" ou "allemagne") une année donnée
tx <- function(pays, an) taux_cm8[[pays]][taux_cm8$annee == an]

# Taux apparent de la dette grecque (intérêts / dette de l'année précédente), 2009-2025
taux_apparent_cm8 <- vapply(2009:2025, function(a) decomposition_dette(a)$i, numeric(1))

#' Taux des emprunts d'État à dix ans, Grèce (rouge) et Allemagne (gris), 2008-2025,
#' moyenne annuelle ; bande grise = plans d'aide 2010-2018 (comme graphe_grece()).
graphe_taux_longs <- function(base_size = 16) {
  pays <- c("Grèce", "Allemagne")
  d <- rbind(data.frame(annee = taux_cm8$annee, pays = pays[1], taux = taux_cm8$grece),
             data.frame(annee = taux_cm8$annee, pays = pays[2], taux = taux_cm8$allemagne))
  d$pays <- factor(d$pays, levels = pays)
  pic <- d[d$pays == pays[1] & d$annee == 2012, ]
  ggplot(d, aes(annee, taux, colour = pays)) +
    annotate("rect", xmin = 2010, xmax = 2018, ymin = -Inf, ymax = Inf,
             fill = "#E5E7EB", alpha = 0.6) +
    geom_hline(yintercept = 0, colour = couleurs_eco[["neutre"]], linewidth = 0.3) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 1.4) +
    annotate("text", x = 2012.4, y = pic$taux, label = "22,5 % en 2012", hjust = 0,
             family = police_cours, size = base_size / 3.4, colour = couleurs_eco[["alerte"]]) +
    scale_colour_manual(values = unname(couleurs_eco[c("alerte", "neutre")])) +
    scale_x_continuous(breaks = c(2008, 2012, 2015, 2018, 2025)) +
    scale_y_continuous(breaks = c(0, 5, 10, 15, 20)) +
    labs(x = NULL, y = "Taux à dix ans (%)",
         caption = "Bande grise : plans d'aide, 2010-2018.\nSource : Eurostat (irt_lt_mcby_a), série téléchargée le 21/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(plot.caption.position = "plot")
}

#' Chômage des 15-74 ans (% des actifs) par groupe, au pic de 2013 (rouge) et en 2025 (bleu).
#' Un segment relie les deux années : sa longueur mesure la décrue.
#' Trois blocs : génération et genre (une_rt_a), diplôme (lfsa_urgaed), région (lfst_r_lfu3rt).
graphe_chomage_groupes <- function(base_size = 16) {
  blocs <- c("Âge, genre", "Diplôme", "Région")
  noms <- c("Ensemble", "15-24 ans", "Femmes", "Hommes")
  cols <- c("chomage", "chomage_15_24", "chomage_femmes", "chomage_hommes")
  a <- data.frame(bloc = blocs[1], categorie = rep(noms, 2), annee = rep(c(2013, 2025), each = 4),
                  chomage = c(vapply(cols, gr, numeric(1), an = 2013),
                              vapply(cols, gr, numeric(1), an = 2025)))
  r <- repartition_cm8[repartition_cm8$annee %in% c(2013, 2025) & repartition_cm8$groupe != "diplome_total", ]
  r$bloc <- ifelse(r$groupe == "region", blocs[3], blocs[2])
  d <- rbind(a, r[, c("bloc", "categorie", "annee", "chomage")])
  d$bloc <- factor(d$bloc, levels = blocs)
  d$categorie <- factor(d$categorie, levels = rev(unique(d$categorie)))   # ordre de lecture, haut en bas
  d$annee <- factor(d$annee, levels = c(2013, 2025))
  seg <- reshape(d, idvar = c("bloc", "categorie"), timevar = "annee", direction = "wide")
  ggplot(d, aes(chomage, categorie)) +
    geom_segment(data = seg, aes(x = chomage.2025, xend = chomage.2013, y = categorie, yend = categorie),
                 colour = "#D1D5DB", linewidth = 2.2, inherit.aes = FALSE) +
    geom_point(aes(colour = annee), size = 3.2) +
    facet_grid(bloc ~ ., scales = "free_y", space = "free_y") +
    scale_colour_manual(values = unname(couleurs_eco[c("alerte", "demande")])) +
    scale_x_continuous(breaks = seq(0, 60, 20), limits = c(0, 62)) +
    labs(x = "Taux de chômage (% des actifs)", y = NULL,
         caption = "Source : Eurostat (une_rt_a, lfsa_urgaed, lfst_r_lfu3rt),\nséries téléchargées le 21/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          strip.text.y = element_text(family = police_cours, angle = 0, hjust = 0, size = rel(0.8)),
          axis.text = element_text(size = rel(0.8)),
          # diapos (base_size = 24) : étiquettes plus petites, pour que les neuf catégories ne se chevauchent pas
          axis.text.y = element_text(size = rel(if (base_size > 16) 0.62 else 0.8)),
          plot.caption.position = "plot")
}

# ---------------------------------------------------------------------------
# 5 ter. Données : la dette grecque par instrument, titres et prêts, 2007-2025
#    Eurostat, gov_10q_ggdebt (dette trimestrielle des administrations publiques,
#    S13, valeur du 4e trimestre), téléchargé le 22/10/2026.
#    Fichier et provenance : data/cm8/grece_dette_instruments_2007_2025.csv et data/cm8/SOURCES.md.
#    La série distingue l'instrument (titre ou prêt), pas le prêteur.
# ---------------------------------------------------------------------------
instruments_cm8 <- utils::read.csv(here::here("data/cm8/grece_dette_instruments_2007_2025.csv"))

#' Valeur d'une colonne d'un fichier annuel du CM 8 (colonne annee) pour une année
val_cm8 <- function(df, col, an) df[[col]][df$annee == an]

#' Nombre au format français (virgule, espace des milliers, signe moins typographique)
nombre_fr <- function(x) sub("^-", "−", format(x, decimal.mark = ",", big.mark = " ", trim = TRUE))

#' Bande grise des plans d'aide, 2010-2018 (la même que dans graphe_grece())
bande_plans_cm8 <- function() annotate("rect", xmin = 2010, xmax = 2018, ymin = -Inf, ymax = Inf,
                                       fill = "#E5E7EB", alpha = 0.6)

#' Dette publique grecque au 31 décembre (Md€), 2007-2025 : prêts (bleu) et titres de dette (ambre).
#' Les prêts dépassent les titres à partir de 2012 (restructuration de la dette privée, plans d'aide).
graphe_dette_instruments <- function(base_size = 16) {
  series <- c("Prêts", "Titres de dette")
  d <- rbind(data.frame(annee = instruments_cm8$annee, serie = series[1], md = instruments_cm8$prets),
             data.frame(annee = instruments_cm8$annee, serie = series[2], md = instruments_cm8$titres))
  d$serie <- factor(d$serie, levels = series)
  fin <- d[d$annee == max(d$annee), ]
  taille <- base_size / 3.4
  ggplot(d, aes(annee, md, colour = serie)) +
    bande_plans_cm8() +
    geom_line(linewidth = 1.2) +
    geom_point(size = 1.4) +
    geom_text(data = fin, aes(label = serie), hjust = 0, nudge_x = 0.4,
              family = police_cours, size = taille) +
    annotate("text", x = 2012.3, y = 150, hjust = 0, family = police_cours, size = taille * 0.85,
             colour = couleurs_eco[["neutre"]],
             label = "2012 : restructuration de la dette\ndétenue par le secteur privé") +
    scale_colour_manual(values = unname(couleurs_eco[c("demande", "offre")])) +
    # diapos (base_size = 24) : moins d'années sur l'axe, sinon 2007, 2010 et 2012 se chevauchent
    scale_x_continuous(breaks = if (base_size > 16) c(2007, 2012, 2018, 2025) else c(2007, 2010, 2012, 2018, 2025)) +
    scale_y_continuous(breaks = seq(0, 300, 100), limits = c(0, 300)) +
    coord_cartesian(clip = "off") +
    labs(x = NULL, y = "Dette publique (Md€)",
         caption = paste0("Encours au 31 décembre. Bande grise : plans d'aide, 2010-2018.\nSource : Eurostat (gov_10q_ggdebt, 4e trimestre),",
                          if (base_size > 16) "\n" else " ", "téléchargé le 22/10/2026.")) +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", plot.caption.position = "plot",
          plot.margin = margin(10, if (base_size > 16) 170 else 115, 8, 8))
}

# ---------------------------------------------------------------------------
# 5 quater. Données : solde primaire observé et corrigé de la conjoncture, 2006-2025
#    Commission européenne, AMECO, prévisions du printemps 2026 (UBLGIE, UBLGBP,
#    UBLGBPS), téléchargé le 22/10/2026. 2026 et 2027 (prévisions) exclues.
#    Fichier et provenance : data/cm8/grece_solde_primaire_corrige_2006_2025.csv et data/cm8/SOURCES.md.
#    Le solde corrigé dépend d'une estimation du PIB potentiel : une mesure, pas une observation.
# ---------------------------------------------------------------------------
solde_corrige_cm8 <- utils::read.csv(here::here("data/cm8/grece_solde_primaire_corrige_2006_2025.csv"))

#' Solde primaire grec, 2006-2025 : corrigé de la conjoncture (rouge, % du PIB potentiel)
#' et observé (gris, % du PIB) ; ligne zéro ; bande grise = plans d'aide 2010-2018.
graphe_solde_corrige <- function(base_size = 16) {
  series <- c("Corrigé de\nla conjoncture", "Observé")
  d <- rbind(data.frame(annee = solde_corrige_cm8$annee, serie = series[1],
                        solde = solde_corrige_cm8$solde_primaire_corrige),
             data.frame(annee = solde_corrige_cm8$annee, serie = series[2],
                        solde = solde_corrige_cm8$solde_primaire))
  d$serie <- factor(d$serie, levels = series)
  fin <- d[d$annee == max(d$annee), ]
  fin$y <- fin$solde + c(-1.6, 1.2) * base_size / 16   # écarte les étiquettes (3,5 et 4,9)
  taille <- base_size / 3.4
  ggplot(d, aes(annee, solde, colour = serie)) +
    bande_plans_cm8() +
    geom_hline(yintercept = 0, colour = couleurs_eco[["neutre"]], linewidth = 0.4) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 1.4) +
    geom_text(data = fin, aes(y = y, label = serie), hjust = 0, nudge_x = 0.4, lineheight = 0.85,
              family = police_cours, size = taille) +
    annotate("text", x = 2013.2, y = -10.6, hjust = 0, family = police_cours, size = taille * 0.85,
             colour = couleurs_eco[["neutre"]], label = "2013 : mesures ponctuelles") +
    scale_colour_manual(values = unname(couleurs_eco[c("alerte", "neutre")])) +
    scale_x_continuous(breaks = if (base_size > 16) c(2006, 2012, 2018, 2025) else c(2006, 2009, 2012, 2018, 2025)) +
    scale_y_continuous(breaks = seq(-10, 10, 5), labels = nombre_fr) +
    coord_cartesian(ylim = c(-11.5, 11.5), clip = "off") +
    # PIB* : le solde observé est en % du PIB, le solde corrigé en % du PIB potentiel.
    # Version diapo : légende réduite, la source est dans la ligne .wp-source de la diapo.
    labs(x = NULL, y = "Solde primaire (% du PIB*)",
         caption = if (base_size > 16)
           "Bande grise : plans d'aide, 2010-2018.\n* Corrigé de la conjoncture : en % du PIB potentiel."
         else "Bande grise : plans d'aide, 2010-2018. * Corrigé de la conjoncture : en % du PIB potentiel.\nSource : Commission européenne, AMECO (UBLGIE, UBLGBP), printemps 2026,\ntéléchargé le 22/10/2026.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", plot.caption.position = "plot",
          plot.margin = margin(10, if (base_size > 16) 175 else 115, 8, 8))
}

# ---------------------------------------------------------------------------
# 5 quinquies. Données : solde migratoire et solde naturel de la Grèce, 2000-2025
#    Eurostat, demo_gind (CNMIGRAT, NATGROW), téléchargé le 22/10/2026 ; 2025 provisoire.
#    Fichier et provenance : data/cm8/grece_soldes_demographiques_2000_2025.csv et data/cm8/SOURCES.md.
#    Le solde migratoire est calculé par différence : il absorbe les corrections des
#    recensements (2011, 2021).
# ---------------------------------------------------------------------------
demo_cm8 <- utils::read.csv(here::here("data/cm8/grece_soldes_demographiques_2000_2025.csv"))

#' Solde migratoire (bleu) et solde naturel (gris), en milliers de personnes par an, 2000-2025 ;
#' creux du solde migratoire en 2013 annoté ; bande grise = plans d'aide 2010-2018.
graphe_soldes_demographiques <- function(base_size = 16) {
  series <- c("Solde migratoire", "Solde naturel")
  d <- rbind(data.frame(annee = demo_cm8$annee, serie = series[1], milliers = demo_cm8$solde_migratoire / 1000),
             data.frame(annee = demo_cm8$annee, serie = series[2], milliers = demo_cm8$solde_naturel / 1000))
  d$serie <- factor(d$serie, levels = series)
  fin <- d[d$annee == max(d$annee), ]
  creux <- val_cm8(demo_cm8, "solde_migratoire", 2013)
  taille <- base_size / 3.4
  ggplot(d, aes(annee, milliers, colour = serie)) +
    bande_plans_cm8() +
    geom_hline(yintercept = 0, colour = couleurs_eco[["neutre"]], linewidth = 0.4) +
    geom_line(linewidth = 1.2) +
    geom_point(size = 1.4) +
    geom_text(data = fin, aes(label = serie), hjust = 0, nudge_x = 0.5,
              family = police_cours, size = taille) +
    annotate("text", x = 2013.4, y = creux / 1000 - 3, hjust = 0, vjust = 1, family = police_cours,
             size = taille * 0.85, colour = couleurs_eco[["demande"]],
             label = paste(nombre_fr(creux), "en 2013")) +
    scale_colour_manual(values = unname(couleurs_eco[c("demande", "neutre")])) +
    scale_x_continuous(breaks = if (base_size > 16) c(2000, 2010, 2017, 2025) else c(2000, 2010, 2013, 2018, 2025)) +
    scale_y_continuous(breaks = seq(-75, 75, 25), labels = nombre_fr) +
    coord_cartesian(ylim = c(-80, 70), clip = "off") +
    labs(x = NULL, y = "Personnes par an (milliers)",
         # version diapo : légende réduite, source et définitions dans .wp-source et les notes
         caption = if (base_size > 16)
           "Bande grise : plans d'aide, 2010-2018.\nSolde migratoire : y compris ajustement statistique."
         else "Bande grise : plans d'aide, 2010-2018. Solde migratoire : arrivées moins départs,\ny compris ajustement statistique ; solde naturel : naissances moins décès.\nSource : Eurostat (demo_gind), téléchargé le 22/10/2026 ; 2025 provisoire.") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none", plot.caption.position = "plot",
          plot.margin = margin(10, if (base_size > 16) 190 else 125, 8, 8))
}

# ---------------------------------------------------------------------------
# 6. Vérifications : chaque chiffre annoncé dans cours/cm8.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 1e-6) abs(x - y) < tol
r1 <- function(x) round(x, 1)

# Exemple 1 : multiplicateur, c = 0,5 puis c = 0,8
stopifnot(
  proche(multiplicateur(0.5), 2), proche(multiplicateur(0.8), 5),
  proche(vagues_cm8$ajout[1:4], c(10, 5, 2.5, 1.25)),
  proche(vagues_cm8$cumul[1:4], c(10, 15, 17.5, 18.75)),
  proche(multiplicateur(0.5) * 10, 20)
)
# Exemple 2 : boule de neige
stopifnot(
  proche(effet_boule_de_neige(150, 3 - (-5)), 12),   # r = 3 %, g = -5 %
  proche(effet_boule_de_neige(150, 3 - 2), 1.5),     # r = 3 %, g = 2 %
  proche(effet_boule_de_neige(150, 2 - 4), -3),      # r = 2 %, g = 4 %
  proche(tail(trajectoire_dette(150, 4, 6)$d, 1), 150),          # s = 6 stabilise d à 150 %
  proche(effet_boule_de_neige(150, 4), 6),
  proche(r1(tail(trajectoire_dette(150, 4, 0)$d, 1)), 222.0),           # 150 × 1,04^10
  proche(r1(tail(trajectoire_dette(150, -2, 0)$d, 1)), 122.6)           # 150 × 0,98^10
)
# Exemple 3 : coupe de 10 Md€, dette 300, PIB 200
stopifnot(
  proche(100 * coupe_cm8$dette / coupe_cm8$pib, 150),
  proche(r1(ratio_apres_coupe(k = 0.5)), 148.7), proche(r1(ratio_apres_coupe(k = 1.5)), 156.8),
  proche(round(seuil_k_cm8, 2), 0.67),
  ratio_apres_coupe(k = 0.66) < 150, ratio_apres_coupe(k = 0.68) > 150,
  proche(ratio_apres_coupe(k = seuil_k_cm8), 150),
  proche(0.5 / seuil_k_cm8, 0.75), proche(1.5 / seuil_k_cm8, 2.25)   # k × d, d = 1 / seuil = 1,5
)
# Données Eurostat citées dans la page
stopifnot(
  proche(nrow(grece_cm8), 18),
  proche(gr("pib_reel", 2008), 247.3), proche(gr("pib_reel", 2013), 180.5), proche(gr("pib_reel", 2025), 212.9),
  proche(round(var_pct(gr("pib_reel", 2008), gr("pib_reel", 2013))), -27),
  proche(r1(var_pct(gr("pib_reel", 2008), gr("pib_reel", 2025))), -13.9),
  proche(gr("chomage", 2009), 9.8), proche(gr("chomage", 2013), 27.8), proche(gr("chomage", 2025), 8.9),
  proche(max(grece_cm8$chomage, na.rm = TRUE), 27.8), proche(gr("chomage_zone_euro", 2013), 12.2),
  proche(gr("dette", 2010), 147.8), proche(gr("dette", 2013), 180.4), proche(gr("dette", 2018), 189.0),
  proche(gr("dette", 2024), 153.5), proche(gr("dette", 2025), 145.4),
  proche(gr("dette", 2020), 209.4), proche(max(grece_cm8$dette), 209.4),   # pic de 2020 (crise sanitaire)
  # PIB en valeur : 2024 à 0,4 % sous 2008 (« légèrement inférieur », DG Trésor) ; en volume, 2025 à 13,9 % sous 2008
  proche(gr("pib_valeur", 2008), 238.7), proche(gr("pib_valeur", 2024), 237.7),
  proche(r1(var_pct(gr("pib_valeur", 2008), gr("pib_valeur", 2024))), -0.4),
  proche(gr("solde", 2009), -15.4), proche(gr("solde", 2025), 2.0),
  # la dette en euros baisse de 2010 à 2013 pendant que le ratio monte de 33 points
  proche(round(dette_md(2010)), 330), proche(round(dette_md(2013)), 321), proche(round(dette_md(2025)), 363),
  proche(round(gr("dette", 2013) - gr("dette", 2010)), 33),
  proche(r1(var_pct(gr("pib_valeur", 2010), gr("pib_valeur", 2013))), -20.3),
  # décomposition 2011 et 2023
  proche(r1(dec_2011$i), 4.7), proche(r1(dec_2011$croissance), -9.0), proche(r1(dec_2011$ecart), 13.7),
  proche(r1(dec_2011$boule), 20.3), proche(r1(dec_2011$boule) - r1(dec_2011$s), 23.1), proche(r1(dec_2011$s), -2.8), proche(r1(dec_2011$prevu), 23.1),
  proche(r1(dec_2011$observe), 27.3),
  proche(r1(dec_2023$i), 2.1), proche(r1(dec_2023$croissance), 8.7), proche(r1(dec_2023$ecart), -6.7),
  proche(r1(dec_2023$boule), -11.8), proche(r1(dec_2023$boule) - r1(dec_2023$s), -13.7), proche(r1(dec_2023$s), 1.9), proche(r1(dec_2023$prevu), -13.7),
  proche(r1(dec_2023$observe), -13.8),
  # légende de tbl-decomposition : valeurs non arrondies de 2023 (d'où -6,7 et -11,8, et non 2,1 - 8,7 = -6,6)
  proche(round(dec_2023$i, 2), 2.08), proche(round(dec_2023$croissance, 2), 8.74), proche(round(dec_2023$ecart, 2), -6.66),
  # qui perd : jeunes, femmes, pauvreté, territoires, diplômes
  proche(gr("chomage_15_24", 2009), 26.1), proche(gr("chomage_15_24", 2013), 59.2), proche(gr("chomage_15_24", 2025), 19.1),
  proche(gr("chomage_femmes", 2013), 31.7), proche(gr("chomage_hommes", 2013), 24.8),
  proche(gr("chomage_femmes", 2025), 11.2), proche(gr("chomage_hommes", 2025), 7.0),
  proche(gr("pauvrete_ue2020", 2008), 28.1), proche(gr("pauvrete_ue2020", 2014), 36.0),
  proche(max(grece_cm8$pauvrete_ue2020, na.rm = TRUE), 36.0), proche(gr("pauvrete_ue2030", 2025), 27.5),
  proche(nrow(repartition_cm8), 16),
  # total 2013 du tableau par diplôme (lfsa_urgaed), cité dans les légendes : 27,5 % au lieu de 27,8 %
  proche(with(repartition_cm8, chomage[groupe == "diplome_total" & annee == 2013]), 27.5),
  # solde primaire de 2010 (solde + intérêts) et prix en baisse de 2012 à 2016 (déflateur du PIB)
  proche(r1(gr("solde", 2010) + gr("interets", 2010)), -5.3),
  all(diff(grece_cm8$pib_valeur / grece_cm8$pib_reel)[grece_cm8$annee[-1] %in% 2012:2016] < 0),
  proche(r1(var_pct(gr("pib_valeur", 2012) / gr("pib_reel", 2012), gr("pib_valeur", 2013) / gr("pib_reel", 2013))), -2.0),
  dette_md(2013) < dette_md(2010),
  proche(gr("dette", 2022), 177.8),
  # chômage par région et par diplôme (2008, 2013, 2025)
  proche(with(repartition_cm8, chomage[categorie == "Attique"]), c(6.7, 28.7, 8.1)),
  proche(with(repartition_cm8, chomage[categorie == "Égée méridionale"]), c(8.4, 21.3, 7.3)),
  proche(with(repartition_cm8, chomage[categorie == "Macédoine-Occidentale"]), c(12.5, 31.6, 15.3)),
  proche(with(repartition_cm8, chomage[categorie == "Diplôme inférieur au lycée"])[1:2], c(7.5, 29.8)),
  proche(with(repartition_cm8, chomage[categorie == "Diplôme du supérieur"])[1:2], c(6.4, 20.4)),
  # montants des plans (MES) : 52,9 + 141,8 + 32,1 + 61,9 ≈ 289 Md€
  proche(round(sum(plans_cm8)), 289),
  # reprise 2018-2024 : +11 % en six ans, moins de 2 % par an
  proche(gr("pib_reel", 2018), 188.0), proche(gr("pib_reel", 2024), 208.6),
  proche(round(reprise_cm8$totale), 11), reprise_cm8$par_an < 2
)
# Taux à dix ans (fig-taux-longs) et chômage par groupe (fig-chomage-groupes)
stopifnot(
  proche(nrow(taux_cm8), 18), identical(taux_cm8$annee, 2008:2025),
  proche(tx("grece", 2008), 4.8), proche(tx("allemagne", 2008), 3.98),
  proche(tx("grece", 2012), 22.5), proche(max(taux_cm8$grece), 22.5),
  proche(tx("allemagne", 2012), 1.5), proche(tx("grece", 2012) - tx("allemagne", 2012), 21),
  proche(tx("grece", 2015), 9.67), tx("grece", 2015) > tx("grece", 2014),
  proche(tx("grece", 2025), 3.37), proche(tx("allemagne", 2025), 2.59),
  proche(r1(tx("grece", 2025) - tx("allemagne", 2025)), 0.8),
  proche(r1(max(taux_apparent_cm8)), 4.7),
  proche(with(repartition_cm8, chomage[categorie == "Diplôme inférieur au lycée" & annee == 2025]), 11.8),
  proche(with(repartition_cm8, chomage[categorie == "Diplôme du supérieur" & annee == 2025]), 6.6),
  proche(with(repartition_cm8, chomage[categorie == "Diplôme inférieur au lycée" & annee == 2013]), 29.8),
  # 2013 : chômage > 20 % dans tous les groupes, maximum chez les 15-24 ans
  min(repartition_cm8$chomage[repartition_cm8$annee == 2013],
      gr("chomage", 2013), gr("chomage_15_24", 2013), gr("chomage_femmes", 2013), gr("chomage_hommes", 2013)) > 20,
  gr("chomage_15_24", 2013) > max(repartition_cm8$chomage[repartition_cm8$annee == 2013]),
  # 2025 : plus élevé chez les femmes, les moins diplômés et en Macédoine-Occidentale
  gr("chomage_femmes", 2025) > gr("chomage_hommes", 2025),
  with(repartition_cm8, chomage[categorie == "Diplôme inférieur au lycée" & annee == 2025] >
                        chomage[categorie == "Diplôme du supérieur" & annee == 2025]),
  with(repartition_cm8, chomage[categorie == "Macédoine-Occidentale" & annee == 2025] >
                        max(chomage[groupe == "region" & annee == 2025 & categorie != "Macédoine-Occidentale"]))
)
# Dette par instrument (fig-dette-instruments), solde primaire corrigé (fig-solde-corrige)
# et soldes démographiques (fig-soldes-demographiques) : valeurs citées dans la page
v <- function(df, col, an) val_cm8(df, col, an)
stopifnot(
  identical(instruments_cm8$annee, 2007:2025), identical(solde_corrige_cm8$annee, 2006:2025),
  identical(demo_cm8$annee, 2000:2025),
  # même dette totale, à moins de 1 Md€ près, que la série annuelle (gov_10dd_edpt1) : 330, 321 et 363 Md€
  abs(v(instruments_cm8, "dette_totale", 2010) - dette_md(2010)) < 1,
  abs(v(instruments_cm8, "dette_totale", 2013) - dette_md(2013)) < 1,
  abs(v(instruments_cm8, "dette_totale", 2025) - dette_md(2025)) < 1,
  proche(v(instruments_cm8, "titres", 2011), 251.6), proche(v(instruments_cm8, "prets", 2011), 103.5),
  proche(v(instruments_cm8, "titres", 2012), 93.4), proche(v(instruments_cm8, "prets", 2012), 210.6),
  proche(v(instruments_cm8, "prets", 2013), 241.0),
  proche(v(instruments_cm8, "titres", 2018), 52.9), proche(v(instruments_cm8, "titres", 2025), 98.0),
  proche(v(instruments_cm8, "prets", 2025), 257.2),
  # les titres dominent jusqu'en 2011, les prêts à partir de 2012
  all(with(instruments_cm8, titres[annee <= 2011] > prets[annee <= 2011])),
  all(with(instruments_cm8, prets[annee >= 2012] > titres[annee >= 2012])),
  # solde primaire 2009-2012 : +14,8 points corrigé, +6,4 points observé
  proche(r1(v(solde_corrige_cm8, "solde_primaire_corrige", 2009)), -8.8),
  proche(r1(v(solde_corrige_cm8, "solde_primaire_corrige", 2012)), 6.0),
  proche(r1(v(solde_corrige_cm8, "solde_primaire_corrige", 2012) - v(solde_corrige_cm8, "solde_primaire_corrige", 2009)), 14.8),
  proche(r1(v(solde_corrige_cm8, "solde_primaire", 2009)), -10.3),
  proche(r1(v(solde_corrige_cm8, "solde_primaire", 2012)), -3.9),
  proche(r1(v(solde_corrige_cm8, "solde_primaire", 2012) - v(solde_corrige_cm8, "solde_primaire", 2009)), 6.4),
  # AMECO et Eurostat (solde + intérêts) s'accordent sur 2010 : -5,3 %
  proche(r1(v(solde_corrige_cm8, "solde_primaire", 2010)), r1(gr("solde", 2010) + gr("interets", 2010))),
  # mesures ponctuelles de 2013 : solde structurel moins solde corrigé, environ 8,6 points
  proche(r1(v(solde_corrige_cm8, "solde_primaire_structurel", 2013) - v(solde_corrige_cm8, "solde_primaire_corrige", 2013)), 8.6),
  # solde migratoire : négatif de 2010 à 2017 (-282 633 en tout), creux de -68 052 en 2013,
  # positif en 2018-2019, négatif en 2020-2021, positif depuis 2022 (+54 135 en 2024)
  with(demo_cm8, all(solde_migratoire[annee %in% 2010:2017] < 0)),
  with(demo_cm8, all(solde_migratoire[annee < 2010] > 0)),
  proche(with(demo_cm8, sum(solde_migratoire[annee %in% 2010:2017])), -282633),
  proche(v(demo_cm8, "solde_migratoire", 2013), -68052), proche(min(demo_cm8$solde_migratoire), -68052),
  with(demo_cm8, all(solde_migratoire[annee %in% c(2018, 2019, 2022:2025)] > 0)),
  with(demo_cm8, all(solde_migratoire[annee %in% 2020:2021] < 0)),
  proche(v(demo_cm8, "solde_migratoire", 2024), 54135),
  # solde naturel : négatif chaque année depuis 2011, entre -55 000 et -64 000 depuis 2021
  with(demo_cm8, all(solde_naturel[annee >= 2011] < 0)),
  with(demo_cm8, all(solde_naturel[annee >= 2021] >= -64000 & solde_naturel[annee >= 2021] <= -55000))
)
rm(v)
