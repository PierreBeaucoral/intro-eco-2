# theme_cours.R
# Thème ggplot2 « Working Paper » : source unique des couleurs de graphiques du cours.
#
# Conventions :
#   - demande = azur, offre = ambre, équilibre = encre ; pas de légende,
#     on étiquette les courbes en bout de trait.
#   - un déplacement de courbe = même teinte, trait tireté, étiquette primée (D', O').
#   - pas de titre dans le graphique (INV-12) : le titre va dans fig-cap.
#
# Usage dans un .qmd (execute-dir: project) :
#   source(here::here("R/theme_cours.R"))
#   ggplot(...) + theme_cours()            # site, fiches
#   ggplot(...) + theme_cours(base_size = 24)   # diapos

library(ggplot2)

# Teintes tirées de ggtrout et MVZlibrary (github.com/eachambers), recopiées en dur
# pour ne pas dépendre de paquets GitHub au rendu. Contraste sur blanc >= 3,7:1 ;
# colorblindcheck::palette_check() : distance minimale >= 15 pour les trois daltonismes.
couleurs_eco <- c(
  demande   = "#2073b7",  # azur          MVZlibrary theAuk[2]
  offre     = "#ac7d0d",  # ambre         ggtrout brook2[1]
  equilibre = "#3e474a",  # encre         ggtrout greenback[1]
  alerte    = "#a13549",  # rouge         MVZlibrary theAuk[8] : chômage, perte sèche, écart à commenter
  neutre    = "#757877"   # gris          ggtrout brook1[5] : repères, pointillés, séries de contexte
)
ordre_series <- unname(couleurs_eco[c("demande", "offre", "alerte", "neutre")])

# STIX Two Text si installée, sinon la serif du système.
police_cours <- if ("STIX Two Text" %in% systemfonts::system_fonts()$family) "STIX Two Text" else "serif"

theme_cours <- function(base_size = 16, donnees = FALSE) {
  encre <- couleurs_eco[["equilibre"]]
  t <- theme_minimal(base_size = base_size, base_family = police_cours) %+replace%
    theme(
      plot.background  = element_rect(fill = "#FFFFFF", colour = NA),
      panel.grid       = element_blank(),
      axis.line        = element_line(colour = encre, linewidth = 0.6,
                                      arrow = grid::arrow(length = grid::unit(0.2, "cm"), type = "closed")),
      axis.ticks       = element_blank(),
      axis.text        = element_text(colour = encre),   # graphique théorique : étiqueter P*, Q* via scale_*(breaks, labels)
      axis.title.x     = element_text(colour = encre, hjust = 1, margin = margin(t = 6)),
      axis.title.y     = element_text(colour = encre, hjust = 1, angle = 90, margin = margin(r = 6)),
      legend.position  = "none",
      plot.title       = element_blank(),
      plot.caption     = element_text(colour = couleurs_eco[["neutre"]], size = rel(0.75), hjust = 0),
      plot.margin      = margin(10, 14, 8, 8)
    )
  if (donnees) {
    t <- t + theme(
      panel.grid.major.y = element_line(colour = "#D1D5DB", linewidth = 0.4),
      axis.line.y = element_blank(),
      legend.position = "top", legend.justification = "left", legend.title = element_blank()
    )
  }
  t
}
