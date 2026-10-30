# Synthèses dessinées en TikZ

Dix planches de fin de CM, entièrement vectorielles, sur fond blanc, en format 16:9.
Les sources pédagogiques restent les dix pages de cours : les planches résument des
mécanismes et ne constituent pas une nouvelle source de données.

## Fichiers à modifier

- planches/cmN.tex : dessin et texte du CM N.
- style.tex : palette, typographie et pictogrammes communs.
- main.tex : recueil des dix planches.
- catalogue.json : noms des exports et descriptions accessibles. Le titre est lu
  directement dans la source TikZ de chaque CM.

Aucune image générée par IA n'entre dans les dessins. Aucun service distant,
aucune image externe, aucune part aléatoire. Les pictogrammes sont tracés en TikZ.
Les essais ImageGen ont été abandonnés au choix de TikZ.

## Planches de notion (hors des dix synthèses)

- positif-normatif.tex : analyse positive / normative, format 32 x 18 cm, pour le PDF du CM 1.
- positif-normatif-compact.tex : même dessin en deux volets superposés (16 x 19 cm), flottant
  à droite du texte sur le site (classe .wp-cote, assets/components.scss).

Vert et violet reprennent le code couleur positif / normatif du site. build.py les compile
après les dix planches (liste NOTIONS), avec les mêmes contrôles ; elles n'entrent ni dans
le recueil ni dans la galerie.

## Reconstruire

Dépendances : Python 3.10+, pypdf, une distribution TeX avec TikZ, Latin Modern,
amsmath et geometry, et Poppler (pdftoppm, pdftocairo).

Depuis la racine du projet :

~~~sh
python3 illustrations/facilitation/build.py
~~~

Depuis ce dossier :

~~~sh
python3 build.py
~~~

La compilation s'arrête en cas d'erreur, d'avertissement de fonte, de débordement,
de page manquante, de bitmap dans le PDF, de collision entre textes ou de marge
insuffisante. Les boîtes TikZ réelles sont mesurées à la compilation : 0,5 cm au
bord de la planche et 0,3 cm entre les textes. Les pictogrammes et flèches font
en complément l'objet d'un contrôle visuel. Le rendu est déterministe dans le même
environnement ; des versions différentes de TeX ou Poppler peuvent modifier les octets
des fichiers sans changer le dessin.

Les sorties sont dans cours/img/facilitation-graphique/ :

- les-dix-cours.pdf : recueil vectoriel, dix pages ;
- cmN-theme.pdf, .svg, .png : exports par cours ;
- galerie.html : galerie locale ;
- dessins-tikz.zip : sources et exports ;
- manifest.json : empreintes SHA-256.
- audit-geometrie.json et audit-noeuds.csv : mesures des boîtes des textes.

Pour le site Quarto et les diapos, utiliser le SVG. Pour une inclusion LaTeX,
utiliser le PDF. Le PNG est un format de compatibilité, pas la source du dessin.

## Choix pédagogiques

Chaque planche comporte trois scènes et une précaution de lecture. Le dessin
présente le mécanisme central, sans prétendre résumer tous les outils du CM.

Les garde-fous principaux sont : offre et demande distinctes (CM1) ;
versement et incidence de la taxe distincts (CM2, CM9) ; stock de médicaments
inchangé par le rationnement (CM3) ; effet théorique conditionnel sur les loyers
(CM4) ; recettes fiscales distinctes de la perte sèche (CM5, CM9) ; capital
remboursé distingué des intérêts (CM6) ; désinflation distincte de la déflation
(CM7) ; dette en niveau distincte du ratio dette / PIB (CM8) ; dommage physique
inchangé par le taux d'actualisation (CM10).
