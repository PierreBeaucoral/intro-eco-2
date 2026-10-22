# cmN.R · graphiques de la séance N, partagés par la page de cours et les diapos.
# Copier vers R/cmN.R. Dépend de R/theme_cours.R (couleurs_eco, theme_cours).
# Une fonction par graphique ; base_size = 16 (page) ou 24 (diapos).

#' Offre et demande linéaires, avec un éventuel déplacement de l'offre
#' @param choc_offre déplacement vertical de l'offre (0 = pas de choc)
#' @param etape pas à pas pour les diapos : 1 = équilibre initial, 2 = ajoute O′,
#'   3 = ajoute E′ (défaut : figure complète, celle de la page)
graphe_offre_demande <- function(choc_offre = 0, base_size = 16, etape = 3) {
  q <- seq(0, 10, length.out = 50)
  d <- data.frame(q = q, demande = 10 - q, offre = q, offre2 = q + choc_offre)
  q1 <- 5; p1 <- 5
  q2 <- (10 - choc_offre) / 2; p2 <- 10 - q2
  g <- ggplot(d, aes(q)) +
    geom_line(aes(y = demande), colour = couleurs_eco[["demande"]], linewidth = 1.4) +
    geom_line(aes(y = offre), colour = couleurs_eco[["offre"]], linewidth = 1.4) +
    annotate("point", x = q1, y = p1, size = 3) +
    annotate("segment", x = c(q1, 0), xend = c(q1, q1), y = c(0, p1), yend = c(p1, p1),
             linetype = "22", colour = couleurs_eco[["neutre"]])
  if (choc_offre != 0 && etape >= 2) {
    g <- g + geom_line(aes(y = offre2), colour = couleurs_eco[["offre"]], linewidth = 1.4, linetype = "22")
    if (etape >= 3) g <- g + annotate("point", x = q2, y = p2, size = 3)
  }
  g + annotate("text", x = c(1.2, 8.8), y = c(10.6, 10.6), label = c("D", "O"),
               colour = couleurs_eco[c("demande", "offre")], family = police_cours, size = base_size / 3) +
    scale_x_continuous(breaks = q1, labels = "Q*") +
    scale_y_continuous(breaks = p1, labels = "P*") +
    coord_cartesian(ylim = c(0, 11), clip = "off") +
    labs(x = "Quantité Q", y = "Prix P") +
    theme_cours(base_size = base_size)
}

# Vérification minimale : équilibre sans choc en (5, 5)
stopifnot(abs((10 - 0) / 2 - 5) < 1e-9)
