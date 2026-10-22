// Working Paper · appel du gabarit (remplace le partiel `typst-show.typ` de Quarto).
// Ajoute l'URL de l'auteur, que le partiel d'origine ne transmet pas.
#show: doc => article(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    ( name: [$it.name.literal$],
      url: $if(it.url)$"$it.url$"$else$none$endif$,
      affiliation: $if(it.affiliations)$[$for(it.affiliations)$$it.name$$sep$, $endfor$]$else$none$endif$ ),
$endif$
$endfor$
    ),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc_title: [$toc-title$],
$endif$
  toc_depth: $toc-depth$,
  doc,
)
