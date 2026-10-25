// Working Paper · gabarit PDF (Typst) des pages de cours et des TD.
// Remplace le partiel `typst-template.typ` de Quarto (fonction `article`).
// Couleurs : celles de assets/theme-light.scss. Encadrés : appelés par assets/typst/wp-typst.lua.

#let wp-encre = rgb("#111111")
#let wp-encre-2 = rgb("#4B5563")
#let wp-filet = rgb("#D1D5DB")
#let wp-accent = rgb("#0062C4")
#let wp-offre = rgb("#B45309")
#let wp-rouge = rgb("#B42318")
#let wp-teinte = rgb("#F1F5FB")
#let wp-positif = rgb("#067647")   // analyse positive (theme-light.scss)
#let wp-normatif = rgb("#6941C6")  // analyse normative
#let wp-serif = ("STIX Two Text", "STIX Two Math")  // Math : flèches et ≈ absentes de Text
#let wp-ui = ("IBM Plex Sans",)
#let wp-mono = ("IBM Plex Mono",)
#set text(font: wp-serif, lang: "fr")

// Étiquette en capitales, comme le ::before des encadrés du site
#let wp-etiquette(label, couleur) = text(font: wp-ui, weight: "semibold", size: 7.5pt, tracking: 0.06em, fill: couleur, upper(label))

// Un bloc court (moins de 40 % de la page) ne se coupe pas ; un bloc long se coupe, étiquette collée au texte.
// Largeur et hauteur utiles : A4 moins les marges de `article` (2 × 2,3 cm ; 2,4 + 2,2 cm). tete: none = pas d'étiquette.
#let wp-bloc(..args, tete, body) = context {
  let contenu = if tete == none { body } else [#block(sticky: true, below: 0.5em, tete)#body]
  let h = measure(block(width: 16.4cm, ..args, contenu)).height
  block(width: 100%, breakable: h > 0.4 * 25.1cm, ..args, contenu)
}

// Encadré pédagogique (.rappel, .retenir, .piege, .auteur, .methode, .droit) : filet à gauche
// portraits : ((image(...), [crédit]), ...) issus des .wp-portrait, en colonne à droite
#let wp-portraits(portraits) = stack(spacing: 6pt, ..portraits.map(((img, credit)) => box(width: 2.1cm)[
  #block(clip: true, radius: 1pt, below: 3pt, img)
  #set par(justify: false, leading: 0.45em)
  #text(font: wp-ui, size: 6pt, fill: wp-encre-2, credit)
]))
#let wp-encadre(label: "", couleur: wp-encre, fond: none, tirets: false, portraits: (), body) = wp-bloc(
  above: 1.2em, below: 1.2em,
  inset: (left: 10pt, right: 10pt, top: 7pt, bottom: 8pt),
  fill: fond,
  stroke: (left: (paint: couleur, thickness: 1.5pt, dash: if tirets { "dashed" } else { none })),
  wp-etiquette(label, couleur),
  if portraits.len() == 0 { body } else { grid(columns: (1fr, 2.1cm), column-gutter: 10pt, body, wp-portraits(portraits)) })

// Document de TD (.wp-document) : cadre fin, étiquette en Plex Sans
#let wp-document(label: "", body) = wp-bloc(
  above: 1.2em, below: 1.2em, inset: 10pt, stroke: 0.6pt + wp-filet,
  text(font: wp-ui, weight: "semibold", size: 9pt, label), body)

// En-tête de TD (.wp-entete) : métadonnées en mono sur fond teinté
#let wp-entete(..items) = block(width: 100%, fill: wp-teinte, inset: (x: 10pt, y: 7pt), below: 1.5em)[
  #set text(font: wp-mono, size: 8.5pt)
  #items.pos().join(h(1.5em))
]

// Vidéo (.wp-video) : le PDF garde le lien
#let wp-video(url, body) = block(above: 0.9em, below: 0.9em)[
  #text(font: wp-mono, size: 8pt, fill: wp-encre-2)[VIDÉO] #h(0.4em)
  #text(font: wp-ui, size: 9pt)[#link(url)[#body]]
]

// Note pour les chargés de TD (.note-td), dans le corps du PDF
#let wp-note-td(body) = block(width: 100%, above: 1em, below: 1em, inset: (top: 6pt), stroke: (top: 0.6pt + wp-filet))[
  #set text(size: 9pt, fill: wp-encre-2)
  #text(weight: "bold", fill: wp-encre)[Note pour les chargés de TD.] #body
]

#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  lang: "fr",
  region: "FR",
  fontsize: 10.5pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  doc,
) = {
  let courant = if subtitle != none { subtitle } else { title }
  let cours = [Introduction à l'économie 2 · L1 AES et Droit]

  set document(title: title)
  set document(author: authors.map(a => content-to-string(a.name)).join(", ")) if authors != none and authors != ()
  set page(
    paper: "a4",
    margin: (x: 2.3cm, top: 2.4cm, bottom: 2.2cm),
    header: context {
      if here().page() > 1 {
        set text(font: wp-mono, size: 7.5pt, fill: wp-encre-2)
        grid(columns: (1fr, auto), cours, courant)
        v(-4pt)
        line(length: 100%, stroke: 0.4pt + wp-filet)
      }
    },
    footer: context {
      set text(font: wp-mono, size: 7.5pt, fill: wp-encre-2)
      grid(columns: (1fr, auto),
        [#link("https://pierrebeaucoral.github.io/")[Pierre Beaucoral] · #link("https://pierrebeaucoral.github.io/intro-eco-2/")[pierrebeaucoral.github.io/intro-eco-2]],
        [#counter(page).display() / #counter(page).final().first()])
    },
  )
  set text(font: wp-serif, size: fontsize, lang: lang, region: region, fill: wp-encre, number-type: "lining")
  set par(justify: true, leading: 0.62em, spacing: 0.95em)
  set list(indent: 0.6em, spacing: 0.6em)
  set enum(indent: 0.6em, spacing: 0.6em)
  show link: set text(fill: wp-accent)
  show ref: set text(fill: wp-accent)
  show raw: set text(font: wp-mono, size: 0.9em)
  show math.equation: set text(font: "STIX Two Math")

  set heading(numbering: sectionnumbering)
  show heading: set text(weight: "bold", fill: wp-encre)
  show heading: set block(sticky: true)
  show heading.where(level: 1): set text(size: 14pt)
  show heading.where(level: 1): set block(above: 1.8em, below: 0.8em)
  show heading.where(level: 2): set text(size: 11.5pt)
  show heading.where(level: 2): set block(above: 1.4em, below: 0.7em)
  show heading.where(level: 3): set text(size: 10.5pt, style: "italic")

  // Tableaux : filets de type booktabs, en-tête en Plex Sans
  set table(inset: (x: 5pt, y: 4pt), stroke: (x, y) => (
    top: if y == 0 { 0.8pt + wp-encre } else if y == 1 { 0.5pt + wp-encre } else { none },
  ))
  show table: set text(size: 9.5pt)
  show table: set par(justify: false)
  show table.cell.where(y: 0): set text(font: wp-ui, weight: "medium", size: 8.5pt)
  show table: it => block(breakable: false, stroke: (bottom: 0.8pt + wp-encre), it)
  // Définitions et exemples (#def-, #exm-) : filet à gauche, comme .theorem.definition et .example de components.scss.
  // Quarto les rend en figures theorion (kind = nom de l'environnement) ; ces règles, internes à `article`, passent avant le show-frame de Quarto.
  show figure.where(kind: "definition"): it => wp-bloc(inset: (left: 10pt, y: 2pt), stroke: (left: 1.5pt + wp-accent), none, it)
  show figure.where(kind: "example"): it => wp-bloc(inset: (left: 10pt, y: 2pt), stroke: (left: 1.5pt + wp-offre), none, it)
  set image(width: 80%)  // figures R de 7 pouces : 80 % de la colonne suffit à l'impression
  show figure.caption: set text(font: wp-ui, size: 8.5pt, fill: wp-encre-2)
  show figure.caption: set par(justify: false)

  // Bloc titre : métadonnées en mono, titre, sous-titre en italique, auteur lié au site
  block(width: 100%, below: 1.6em, inset: (bottom: 10pt), stroke: (bottom: 0.6pt + wp-filet))[
    #text(font: wp-mono, size: 8pt, fill: wp-encre-2)[#cours · Semestre 2 · 2026-2027]
    #v(0.2em)
    #if title != none { par(justify: false, leading: 0.4em, text(size: 21pt, weight: "semibold", title)) }
    #if subtitle != none { v(0.1em); text(size: 12.5pt, style: "italic", fill: wp-encre-2, subtitle) }
    #if authors != none and authors != () {
      v(0.6em)
      set text(size: 9.5pt)
      for a in authors [
        #text(font: wp-mono, size: 7.5pt, fill: wp-encre-2)[AUTEUR] #h(0.3em)
        #if a.url != none { link(a.url, a.name) } else { a.name }
        #if a.affiliation != none [ · #a.affiliation]
        #linebreak()
      ]
    }
    #if date != none { text(font: wp-mono, size: 7.5pt, fill: wp-encre-2)[#date] }
  ]

  if toc {
    outline(title: toc_title, depth: toc_depth, indent: 1.2em)
  }

  doc
}
