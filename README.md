# Introduction à l'économie 2 · L1 AES et Droit

Site du cours (Quarto) : <https://pierrebeaucoral.github.io/intro-eco-2/>

## Rendu et publication

```sh
# l'anaconda du PATH embarque un pandoc cassé : le retirer pour le rendu
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v anaconda | paste -sd: -)
quarto preview                 # aperçu local
quarto publish gh-pages        # rendu + publication sur la branche gh-pages
```

`quarto publish` publie ce qui est **sur le disque**, commité ou non. Seuls les fichiers listés sous `render` dans `_quarto.yml` sont publiés.

## Arborescence

| Dossier | Contenu |
|---|---|
| `cours/cmN.qmd` | Pages de cours, une par CM (poly et fiche de révision) |
| `slides/cmN.qmd` | Diapos de CM (revealjs, réglages communs dans `slides/_metadata.yml`) |
| `R/cmN.R` | Graphiques de la séance N, partagés par la page et les diapos |
| `td/tdN.qmd` | Sujets de TD (liste : `td.qmd`) (TD 4 et TD 8 : contrôles continus) |
| `methodo/` | Fiches méthode |
| `assets/` | Thème « Working Paper » : `theme-light.scss`, `theme-dark.scss`, `components.scss`, `slides.scss` |
| `assets/typst/`, `assets/fonts/` | Sortie PDF (Typst) des cours et TD : gabarit, filtre des encadrés, polices libres (OFL) |
| `R/theme_cours.R` | Thème ggplot2 et couleurs des graphiques |
| `quality_reports/S2_guide_redaction.md` | **Guide de rédaction** : contrat de tous les contenus (local, non versionné) |
| `_templates/` | Modèles de pages (non publiés) |
| `_drafts/` | Corrigés en préparation (ignoré par git, jamais publié) |
| `_design/` | Propositions de design et maquettes (non publié) |
| `quality_reports/` | Audit de l'ancien cours, journal des décisions, plans (local, non versionné) |

## Publier un corrigé

1. Rédiger le corrigé dans `_drafts/tdN-corrige.qmd` à partir de `_templates/td-corrige.qmd`.
2. Le jour de la publication : `mv _drafts/tdN-corrige.qmd td/`, ajouter le lien dans `td/tdN.qmd`, commiter, `quarto publish gh-pages`. Les fiches enseignant (`_drafts/tdN-fiche-enseignant.qmd`) ne quittent jamais `_drafts/`.

## Encadrés disponibles

Voir le guide de rédaction, § 5. Vidéos YouTube : iframe `youtube-nocookie.com` dans `::: {.wp-video}` (pas le shortcode `{{< video >}}`).
