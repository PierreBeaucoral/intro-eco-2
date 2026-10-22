# check_etape.R · les figures de la page restent identiques après l'ajout de variantes `etape`.
# Usage (depuis la racine) : Rscript _templates/check_etape.R N
# Compare, pour chaque fonction graphe_*() de R/cmN.R appelée avec ses arguments par défaut
# (base_size = 16 et 24), le PNG produit par la version committée (git HEAD) et par la version
# de travail. Sort avec un statut 1 si une figure diffère.
suppressMessages(source(here::here("R/theme_cours.R")))
n <- commandArgs(TRUE)[1]
fichier <- sprintf("R/cm%s.R", n)
tmp <- tempfile(); dir.create(tmp)
ancien <- file.path(tmp, "ancien.R")
system2("git", c("show", sprintf("HEAD:%s", fichier)), stdout = ancien)
a <- new.env(); b <- new.env()
sys.source(ancien, a); sys.source(here::here(fichier), b)
png_md5 <- function(f, bs, nom) {
  out <- file.path(tmp, nom)
  ragg::agg_png(out, 7, 4.6, units = "in", res = 100); print(f(base_size = bs)); invisible(dev.off())
  unname(tools::md5sum(out))
}
fns <- grep("^graphe_", ls(a), value = TRUE)
ecarts <- 0L
for (fn in fns) {
  f <- formals(a[[fn]])
  sans_defaut <- vapply(f, function(x) identical(x, quote(expr = )), logical(1))
  if (any(sans_defaut) || !"base_size" %in% names(f)) { cat("ignorée :", fn, "\n"); next }
  for (bs in c(16, 24)) {
    ok <- identical(png_md5(a[[fn]], bs, "a.png"), png_md5(b[[fn]], bs, "b.png"))
    cat(sprintf("%-30s base_size %2d : %s\n", fn, bs, if (ok) "identique" else "DIFFÉRENTE"))
    if (!ok) ecarts <- ecarts + 1L
  }
}
quit(status = as.integer(ecarts > 0))
