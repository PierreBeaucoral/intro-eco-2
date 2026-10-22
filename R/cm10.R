# cm10.R · graphiques du CM 10 (actualisation, climat entre Nord et Sud),
# partagés par la page de cours (base_size = 16) et les diapos (base_size = 24).
# Dépend de R/theme_cours.R (couleurs_eco, ordre_series, police_cours, theme_cours).
#
# Toutes les valeurs numériques annoncées dans cours/cm10.qmd sont calculées ici
# une seule fois, puis vérifiées par les stopifnot() en fin de fichier.

# ---------------------------------------------------------------------------
# 1. L'outil : la valeur actuelle d'un montant futur
#    valeur actuelle = montant / (1 + delta)^n, n en années, delta en décimal.
# ---------------------------------------------------------------------------

#' Valeur actuelle d'un montant reçu (ou d'un dommage subi) dans n années
#' @param montant montant futur, en euros
#' @param delta taux d'actualisation annuel (0.03 pour 3 %)
#' @param n nombre d'années
valeur_actuelle <- function(montant, delta, n) montant / (1 + delta)^n

# Les trois taux de l'exemple (1 %, 3 %, 5 %) et la table des facteurs d'actualisation
taux_cm10 <- c(0.01, 0.03, 0.05)
facteurs_cm10 <- outer(c(50, 100), taux_cm10, function(n, d) 1 / (1 + d)^n)
dimnames(facteurs_cm10) <- list(c("50 ans", "100 ans"), c("1 %", "3 %", "5 %"))

# Projet de l'Exemple 2 : coûte 100 aujourd'hui, évite un dommage de 1 000 dans 100 ans
projet_cm10 <- list(cout = 100, dommage = 1000, n = 100)
va_projet_cm10 <- valeur_actuelle(projet_cm10$dommage, taux_cm10, projet_cm10$n)
# Taux au-dessus duquel le projet ne vaut plus son coût : (1 + delta)^100 = 10
taux_seuil_cm10 <- 10^(1 / 100) - 1

# Valeur de l'action pour le climat (VAC) : 256 € en 2025, croît au taux public de 3,2 %
vac_cm10 <- list(v2025 = 256, delta = 0.032)
vac_2030_cm10 <- vac_cm10$v2025 * (1 + vac_cm10$delta)^5

# Règle de Ramsey, paramètres d'illustration :
# delta = impatience + aversion à l'inégalité x croissance g (en points de %)
ramsey <- function(impatience, aversion, g) impatience + aversion * g

#' Valeur actuelle de 1 000 € selon l'horizon, pour trois taux d'actualisation.
#' Graphique « outil » : les axes portent des valeurs, car c'est ce qu'on lit.
#' @param base_size 16 (page) ou 24 (diapos)
graphe_actualisation <- function(base_size = 16) {
  n <- 0:100
  d <- do.call(rbind, lapply(seq_along(taux_cm10), function(i)
    data.frame(n = n, va = valeur_actuelle(1000, taux_cm10[i], n),
               taux = names(facteurs_cm10[1, ])[i])))
  fin <- d[d$n == 100, ]
  fin$etiquette <- paste0("δ = ", fin$taux, " : ", round(fin$va), " €")
  fin$y_etiquette <- c(fin$va[1], 95, 5)   # écarte les étiquettes 3 % et 5 %, trop proches
  taille <- base_size / 3.2
  ggplot(d, aes(n, va, colour = taux)) +
    annotate("segment", x = 50, xend = 50, y = 0, yend = 1000,
             linetype = "22", colour = couleurs_eco[["neutre"]]) +
    geom_line(linewidth = 1.3) +
    geom_point(data = fin, size = 2.6) +
    geom_text(data = fin, aes(y = y_etiquette, label = etiquette), hjust = 0, nudge_x = 2.5,
              family = police_cours, size = taille) +
    scale_colour_manual(values = ordre_series[c(1, 2, 3)]) +
    scale_x_continuous(breaks = c(0, 50, 100), labels = c("aujourd’hui", "50 ans", "100 ans"),
                       expand = expansion(mult = c(0, 0))) +
    scale_y_continuous(breaks = c(0, 250, 500, 750, 1000),
                       labels = function(x) format(x, big.mark = " ")) +
    coord_cartesian(xlim = c(0, 100), ylim = c(0, 1050), clip = "off") +
    labs(x = "Dans combien d’années ?", y = "Valeur actuelle (€)") +
    theme_cours(base_size = base_size) +
    theme(plot.margin = margin(10, base_size * 9.5, 8, 8))
}

# ---------------------------------------------------------------------------
# 2. Graphique théorique : l'externalité climatique dépend du taux
#    Q = émissions ; D = bénéfice marginal d'émettre ; Cm = coût privé (constant) ;
#    Cms = Cm + Dm, où Dm = valeur actuelle des dommages futurs d'une tonne.
#    Valeurs fictives, seules les étiquettes apparaissent sur les axes.
# ---------------------------------------------------------------------------
climat_cm10 <- list(d_a = 10, cm = 1, dm_eleve = 2.5, dm_faible = 6)

#' Quantité où la demande D = d_a - Q coupe un coût horizontal c
q_coupe <- function(c) climat_cm10$d_a - c

#' L'optimum d'émissions selon le taux d'actualisation.
#' @param base_size 16 (page) ou 24 (diapos)
graphe_cms_taux <- function(base_size = 16) {
  cm <- climat_cm10$cm
  cms_e <- cm + climat_cm10$dm_eleve
  cms_f <- cm + climat_cm10$dm_faible
  q_star <- q_coupe(cm); q_e <- q_coupe(cms_e); q_f <- q_coupe(cms_f)
  neutre <- couleurs_eco[["neutre"]]; ambre <- couleurs_eco[["offre"]]
  taille <- base_size / 3.2
  ggplot() +
    annotate("segment", x = c(q_star, q_e, q_f), xend = c(q_star, q_e, q_f),
             y = 0, yend = c(cm, cms_e, cms_f), linetype = "22", colour = neutre) +
    annotate("segment", x = 0, xend = 10, y = 10, yend = 0,
             colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    annotate("segment", x = 0, xend = 10, y = cm, yend = cm, colour = ambre, linewidth = 1.4) +
    annotate("segment", x = 0, xend = 10, y = c(cms_e, cms_f), yend = c(cms_e, cms_f),
             colour = ambre, linewidth = 1.4, linetype = "22") +
    annotate("point", x = c(q_star, q_e, q_f), y = c(cm, cms_e, cms_f), size = 3) +
    annotate("text", x = 10.15, y = c(cm, cms_e, cms_f), hjust = 0,
             label = c("Cm (coût privé)", "Cms si δ élevé", "Cms si δ faible"),
             colour = ambre, family = police_cours, size = taille) +
    annotate("text", x = 0.9, y = 9.6, hjust = 0, label = "D (bénéfice d’émettre)",
             colour = couleurs_eco[["demande"]], family = police_cours, size = taille) +
    scale_x_continuous(breaks = c(q_f, q_e, q_star),
                       labels = c("Q°\n(δ faible)", "Q°\n(δ élevé)", "Q*\n")) +
    scale_y_continuous(breaks = NULL) +
    coord_cartesian(xlim = c(0, 10), ylim = c(0, 10.5), clip = "off") +
    labs(x = "Émissions Q", y = "€ par tonne") +
    theme_cours(base_size = base_size) +
    theme(plot.margin = margin(10, base_size * 9, 8, 8),
          axis.text.x = element_text(size = rel(0.8)))
}

# ---------------------------------------------------------------------------
# 3. Graphique de données : part des émissions cumulées et part de la population
#    Source : Global Carbon Budget (2025) et OWID, téléchargé le 21/10/2026
#    (data/cm10/SOURCES.md).
# ---------------------------------------------------------------------------
co2_cm10 <- utils::read.csv(here::here("data/cm10/co2_nord_sud.csv"), encoding = "UTF-8")
monde_cm10 <- co2_cm10[co2_cm10$entite == "Monde", ]
co2_cm10$part_cumul <- 100 * co2_cm10$co2_cumule_1750_2024_t / monde_cm10$co2_cumule_1750_2024_t
co2_cm10$part_pop   <- 100 * co2_cm10$population_2023 / monde_cm10$population_2023

#' Barres horizontales : part du CO2 cumulé (1750-2024) et part de la population (2023)
#' @param base_size 16 (page) ou 24 (diapos)
graphe_parts_co2 <- function(base_size = 16) {
  ordre <- c("États-Unis", "Union européenne (27)", "Chine", "Inde", "Afrique", "France")
  x <- co2_cm10[match(ordre, co2_cm10$entite), ]
  d <- rbind(
    data.frame(entite = x$entite, serie = "CO₂ émis de 1750 à 2024", part = x$part_cumul),
    data.frame(entite = x$entite, serie = "Population (2023)", part = x$part_pop)
  )
  courts <- sub("Union européenne (27)", "UE à 27", ordre, fixed = TRUE)   # libellé court sur l'axe
  d$entite <- factor(courts[match(d$entite, ordre)], levels = rev(courts))
  d$serie <- factor(d$serie, levels = unique(d$serie))
  virgule <- function(v) paste0(format(round(v, 1), decimal.mark = ",", nsmall = 1), " %")
  ggplot(d, aes(part, entite, fill = serie)) +
    geom_col(position = position_dodge(width = 0.8, reverse = TRUE), width = 0.75) +
    geom_text(aes(label = virgule(part)), position = position_dodge(width = 0.8, reverse = TRUE),
              hjust = -0.15, family = police_cours, size = base_size / 3.6,
              colour = couleurs_eco[["equilibre"]]) +
    scale_fill_manual(values = unname(couleurs_eco[c("demande", "neutre")])) +
    scale_x_continuous(limits = c(0, 28), breaks = c(0, 10, 20),
                       labels = function(v) paste0(v, " %")) +
    labs(x = "Part du total mondial", y = NULL,
         caption = "Source : Global Carbon Budget (2025) ; population : HYDE,\nGapminder, Nations unies ; traitement Our World in Data\n(téléchargé le 21/10/2026).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(panel.grid.major.y = element_blank(),
          panel.grid.major.x = element_line(colour = "#D1D5DB", linewidth = 0.4),
          axis.line.x = element_blank(),
          plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# 4. Graphique de données : émissions de CO2 par habitant, 1990-2024
#    Même source et même champ que la section 3 (data/cm10/SOURCES.md).
# ---------------------------------------------------------------------------
flux_cm10 <- utils::read.csv(here::here("data/cm10/co2_par_hab_1990_2024.csv"), encoding = "UTF-8")

#' Courbes : CO2 par habitant de 1990 à 2024, six entités, étiquetées en bout de trait
#' @param base_size 16 (page) ou 24 (diapos)
graphe_flux_co2 <- function(base_size = 16) {
  ordre <- c("États-Unis", "Chine", "Union européenne (27)", "Monde", "Inde", "Afrique")
  courts <- c("États-Unis", "Chine", "UE à 27", "Monde", "Inde", "Afrique")
  d <- flux_cm10
  d$entite <- factor(courts[match(d$entite, ordre)], levels = courts)
  fin <- d[d$annee == max(d$annee), ]
  fin <- fin[order(-fin$co2_par_hab_t), ]
  # Écarte les étiquettes trop proches (UE et Monde, Inde et Afrique) : écart minimal
  # proportionnel à la taille du texte, de haut en bas.
  ecart <- 1.6 * base_size / 16
  fin$y_etiquette <- fin$co2_par_hab_t
  for (i in 2:nrow(fin)) {
    fin$y_etiquette[i] <- min(fin$y_etiquette[i], fin$y_etiquette[i - 1] - ecart)
  }
  # puis de bas en haut, pour que la dernière étiquette ne passe pas sous l'axe
  fin$y_etiquette[nrow(fin)] <- max(fin$y_etiquette[nrow(fin)], 0.6)
  for (i in rev(seq_len(nrow(fin) - 1))) {
    fin$y_etiquette[i] <- max(fin$y_etiquette[i], fin$y_etiquette[i + 1] + ecart)
  }
  couleurs <- c(couleurs_eco[["demande"]], couleurs_eco[["alerte"]], couleurs_eco[["offre"]],
                couleurs_eco[["equilibre"]], couleurs_eco[["neutre"]], couleurs_eco[["neutre"]])
  traits <- c("solid", "solid", "solid", "22", "solid", "13")
  ggplot(d, aes(annee, co2_par_hab_t, colour = entite, linetype = entite)) +
    geom_line(linewidth = 1.2) +
    geom_text(data = fin, aes(y = y_etiquette, label = entite), x = max(d$annee) + 1,
              hjust = 0, family = police_cours, size = base_size / 3.4) +
    scale_colour_manual(values = couleurs) +
    scale_linetype_manual(values = traits) +
    scale_x_continuous(breaks = c(1990, 2000, 2010, 2024), expand = expansion(mult = c(0, 0))) +
    scale_y_continuous(breaks = c(0, 5, 10, 15, 20), labels = function(v) paste0(v, " t")) +
    coord_cartesian(xlim = c(1990, 2024), ylim = c(0, 22), clip = "off") +
    labs(x = NULL, y = "Tonnes de CO₂ par habitant",
         caption = "Source : Global Carbon Budget (2025) ;\ntraitement Our World in Data (téléchargé le 21/10/2026).") +
    theme_cours(base_size = base_size, donnees = TRUE) +
    theme(legend.position = "none",
          plot.margin = margin(10, base_size * 5.5, 8, 8),
          plot.caption = element_text(margin = margin(t = 10)))
}

# ---------------------------------------------------------------------------
# Vérifications : chiffres annoncés dans cours/cm10.qmd
# ---------------------------------------------------------------------------
proche <- function(x, y, tol = 0.01) abs(x - y) < tol

stopifnot(
  # Exemple 1 : 100 € à 10 % donnent 121 € dans deux ans, et réciproquement
  proche(100 * 1.1^2, 121), proche(valeur_actuelle(121, 0.10, 2), 100),
  # Règle de 70 : à 7 %, on divise par 2 tous les 10 ans environ ; 1 000 € à 100 ans ≈ 1 €
  proche(1000 / 2^10, 0.98, 0.01), proche(valeur_actuelle(1000, 0.07, 100), 1.15, 0.01),
  # à 1 %, 1 000 € dans 70 ans valent environ 500 € aujourd'hui
  abs(valeur_actuelle(1000, 0.01, 70) - 500) < 2,
  # Table des facteurs (arrondis du texte)
  proche(round(facteurs_cm10["50 ans", ], 2), c(0.61, 0.23, 0.09)),
  proche(round(facteurs_cm10["100 ans", ], 3), c(0.370, 0.052, 0.008)),
  # Exemple 2 : valeur actuelle du dommage évité (370, 52, 8 €) contre un coût de 100
  proche(round(va_projet_cm10), c(370, 52, 8)),
  identical(va_projet_cm10 > projet_cm10$cout, c(TRUE, FALSE, FALSE)),
  proche(round(100 * taux_seuil_cm10, 1), 2.3),
  # Seuil par la règle de 70 : 1 000 -> 100, un peu plus de 3 divisions par 2 en 100 ans,
  # soit une tous les 30 ans environ, donc 70 / 30 ≈ 2,3 %
  2^3 < 10, 2^4 > 10, proche(round(70 / 30, 1), 2.3),
  # Exemple 1, étape 5 : 370 € à 1 % contre 1,15 € à 7 %, rapport « environ 300 »
  abs(valeur_actuelle(1000, 0.01, 100) / valeur_actuelle(1000, 0.07, 100) - 300) < 30,
  # Écart entre 1 % et 5 % sur un siècle : 370 € contre 8 €, rapport « près de 50 »
  abs(valeur_actuelle(1000, 0.01, 100) / valeur_actuelle(1000, 0.05, 100) - 50) < 2,
  # Exemple 3 : VAC 256 € en 2025 à 3,2 % par an : environ 264 € en 2026 et 300 € en 2030
  proche(round(vac_cm10$v2025 * 1.032), 264), proche(round(vac_2030_cm10), 300),
  # Ramsey (illustration) : 0,1 + 1 x 1,3 = 1,4 ; 1,5 + 2 x 2 = 5,5
  proche(ramsey(0.1, 1, 1.3), 1.4), proche(ramsey(1.5, 2, 2), 5.5),
  # Tonnes de carbone et de CO2 : 1 tC = 44 / 12 ≈ 3,7 tCO2 ; 30 $ et 300 $ par tC
  # font environ 8 $ et 80 $ par tCO2 ; 50 à 235 $ par tC font 14 à 64 $ par tCO2
  proche(round(44 / 12, 1), 3.7),
  proche(round(30 / 3.7), 8), abs(300 / 3.7 - 80) < 2,
  proche(round(c(50, 235) / 3.7), c(14, 64)),
  # Graphique théorique : Q° (δ faible) < Q° (δ élevé) < Q*
  q_coupe(climat_cm10$cm + climat_cm10$dm_faible) < q_coupe(climat_cm10$cm + climat_cm10$dm_eleve),
  q_coupe(climat_cm10$cm + climat_cm10$dm_eleve) < q_coupe(climat_cm10$cm)
)

# Données Nord-Sud (arrondis cités dans la page)
parts <- function(e) unlist(co2_cm10[co2_cm10$entite == e, c("part_cumul", "part_pop")])
stopifnot(
  nrow(co2_cm10) == 8,
  proche(round(parts("États-Unis"), 1), c(23.5, 4.2)),
  proche(round(parts("Union européenne (27)"), 1), c(16.3, 5.6)),
  proche(round(parts("Chine"), 1), c(15.4, 17.6)),
  proche(round(parts("Inde"), 1), c(3.6, 17.8)),
  proche(round(parts("Afrique"), 1), c(2.9, 18.3)),
  proche(round(parts("France"), 1), c(2.2, 0.8)),
  # États-Unis + UE : « près de 40 % » du CO2 cumulé, « moins de 10 % » de la population
  (parts("États-Unis") + parts("Union européenne (27)"))[1] >= 38,
  (parts("États-Unis") + parts("Union européenne (27)"))[1] < 40,
  (parts("États-Unis") + parts("Union européenne (27)"))[2] < 10,
  proche(round(monde_cm10$co2_cumule_1750_2024_t / 1e9), 1849),
  proche(co2_cm10$co2_par_hab_2024_t[co2_cm10$entite == "États-Unis"], 14.2),
  proche(co2_cm10$co2_par_hab_2024_t[co2_cm10$entite == "Chine"], 8.66),
  proche(co2_cm10$co2_par_hab_2024_t[co2_cm10$entite == "Union européenne (27)"], 5.39),
  proche(co2_cm10$co2_par_hab_2024_t[co2_cm10$entite == "Monde"], 4.73),
  proche(co2_cm10$co2_par_hab_2024_t[co2_cm10$entite == "France"], 3.97),
  proche(co2_cm10$co2_par_hab_2024_t[co2_cm10$entite == "Inde"], 2.2),
  proche(co2_cm10$co2_par_hab_2024_t[co2_cm10$entite == "Nigeria"], 0.58),
  proche(co2_cm10$co2_par_hab_1990_t[co2_cm10$entite == "Chine"], 2.15)
)

# Données par habitant 1990-2024 (@fig-flux-co2 et sa phrase de lecture)
flux <- function(e, a) flux_cm10$co2_par_hab_t[flux_cm10$entite == e & flux_cm10$annee == a]
ue <- "Union européenne (27)"
stopifnot(
  nrow(flux_cm10) == 6 * 35,
  # cohérence avec co2_nord_sud.csv (mêmes fichiers source)
  proche(flux("Chine", 1990), 2.15), proche(flux("Chine", 2024), 8.66),
  proche(flux("États-Unis", 1990), 20.25), proche(flux(ue, 2024), 5.39),
  # États-Unis : 20,3 t → 14,2 t, soit environ −30 %
  proche(round(100 * (flux("États-Unis", 2024) / flux("États-Unis", 1990) - 1)), -30),
  # UE à 27 : 9,2 t → 5,4 t, soit une baisse de plus de 40 %
  flux(ue, 2024) / flux(ue, 1990) < 0.6,
  # Chine : 2,2 t → 8,7 t, multipliée par 4 environ
  proche(round(flux("Chine", 2024) / flux("Chine", 1990)), 4),
  # Chine au-dessus de l'UE chaque année depuis 2017
  all(sapply(2017:2024, function(a) flux("Chine", a) > flux(ue, a))),
  flux("Chine", 2016) < flux(ue, 2016),
  # Afrique : autour de 1 t sur toute la période
  all(abs(flux_cm10$co2_par_hab_t[flux_cm10$entite == "Afrique"] - 1) < 0.2)
)
