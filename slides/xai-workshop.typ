#import "../template/iep-slides.typ": *
#import "@preview/cetz:0.4.2" as cetz
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#show: doc => iep-presentation(
  course: "Atelier IA Explicable (XAI)",
  year: "2026",
  author: "Mickael Temporão",
  affiliation: "Sciences Po Bordeaux | Centre Émile Durkheim",
  topic: "De la régression aux grands modèles de langage",
  doc,
)

// ============================================================================
// Helpers locaux : esthetique editoriale suisse (monochrome + rouge IEP)
// ============================================================================

#let num-head(num, title, accent: iep-anthracite) = [
  #line(length: 100%, stroke: 1.5pt + accent)
  #v(8pt)
  #grid(
    columns: (auto, 1fr),
    gutter: 10pt,
    align: horizon,
    text(font: font-heading, size: 20pt, weight: "bold", fill: accent)[#num],
    text(font: font-heading, size: 15pt, weight: "bold", fill: iep-anthracite)[#title],
  )
]

#let callout-strip(label, body, accent: iep-red) = block(
  width: 100%,
  fill: iep-surface,
  stroke: (left: 3pt + accent),
  inset: (x: 14pt, y: 9pt),
  [
    #grid(
      columns: (auto, 1fr),
      gutter: 12pt,
      align: horizon,
      text(font: font-body, size: 10pt, weight: "bold", fill: accent, tracking: 0.8pt)[#upper(label)],
      text(size: 11.5pt, fill: iep-anthracite)[#body],
    )
  ],
)

// ============================================================================
// Slide 1 : Page de titre
// ============================================================================

#title-slide(
  lecture-num: "Atelier",
  course-name: "IA Explicable (XAI)",
  title: "De la régression aux grands modèles de langage",
  author: "Mickael Temporão",
  affiliation: "Sciences Po Bordeaux | Centre Émile Durkheim",
  year: "2026",
)

// ============================================================================
// Slide 2 : Feuille de route
// ============================================================================

#slide(
  category: "Programme (35 à 40 min)",
  title: "Feuille de route de l'atelier",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 28pt,
    align: top,
    [
      #num-head("01", "Comprendre (15 à 20 min)", accent: iep-anthracite)
      #v(10pt)
      #set text(size: 12.5pt)
      - #strong[Modèles et algorithmes] : simplifier le réel et apprendre par l'exemple.
      - #strong[De la boîte de verre à la boîte noire] : comparer une régression lisible (`2` puis `7` paramètres) à un réseau de neurones (`329` paramètres) et aux LLM.
      - #strong[IA Explicable (XAI)] : comment interroger un modèle devenu opaque, auditer les biais et éviter les pièges causaux.
    ],
    [
      #num-head("02", "Pratiquer (15 à 20 min)", accent: iep-red)
      #v(10pt)
      #set text(size: 12.5pt)
      - #strong[Application interactive] : manipuler en direct le « Workshop IA Explicable (XAI) » (`100` points réels cliquables, `6` variables socio-économiques).
      - #strong[Google Colab] : exécuter pas à pas une régression en Python (`statsmodels`) sans prérequis technique.
      - #strong[Expérimentation] : faire varier un paramètre à la fois, tester le double audit de biais et comparer boîte de verre et boîte noire.
    ],
  )

  #v(18pt)

  #callout-strip(
    "Fil rouge",
    [
      Des #strong[données réelles d'enquête (`ANES 2024`, `N = 4 734` répondant·es, USA 2024)] : prédire le #strong[revenu annuel du foyer] (`revenu_annuel`, `$ / an`), visualiser tous les résidus sur #strong[`100` points cliquables], et mener un #strong[double audit de biais] (`femme` et `minorite`).
    ],
    accent: iep-red,
  )
]

// ============================================================================
// Slide 3 : Section 01
// ============================================================================

#section-slide(
  num: "01",
  title: "Modèles, algorithmes et apprentissage",
  subtitle: "Trois notions simples pour démystifier l'intelligence artificielle",
  tag: "Partie 1 : Concepts clés",
)

// ============================================================================
// Slide 4 : Qu'est-ce qu'un modèle ?
// ============================================================================

#slide(
  category: "Fondations",
  title: "Qu'est-ce qu'un modèle ?",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 28pt,
    align: top,
    [
      #text(font: font-heading, size: 15pt, weight: "bold", fill: iep-anthracite)[
        Une simplification utile du réel
      ]
      #v(8pt)
      #set text(size: 12.5pt)
      Un modèle n'est pas une copie exacte du monde : c'est une #strong[heuristique] (une représentation simplifiée pour s'orienter) qui retient l'essentiel et met de côté le bruit.
      #v(8pt)
      - #strong[Ce qu'on retire] rend la représentation lisible.
      - #strong[Ce qu'on garde] dépend de la question posée.
      - En sciences sociales, modéliser aide à résumer des tendances collectives sans prétendre épuiser chaque parcours individuel.

      #v(16pt)

      #block(
        width: 100%,
        fill: iep-surface,
        stroke: (left: 3pt + iep-red),
        inset: (x: 14pt, y: 10pt),
        [
          #text(font: font-heading, size: 13.5pt, style: "italic", fill: iep-anthracite)[
            « Tous les modèles sont faux, mais certains sont utiles. »
          ]
          #v(4pt)
          #align(right, text(size: 11pt, weight: "bold", fill: iep-red)[
            George E. P. Box (1976)
          ])
        ],
      )
    ],
    [
      #text(font: font-heading, size: 15pt, weight: "bold", fill: iep-anthracite)[
        Photo satellite vs plan du tram de Bordeaux
      ]
      #v(8pt)
      #set text(size: 11.5pt)
      #text(weight: "bold", fill: iep-gray)[Photo satellite :] fidèle au mètre près (toits, arbres, ruelles), mais inutilisable pour trouver sa correspondance en 5 secondes.
      #v(8pt)
      #line(length: 100%, stroke: 0.6pt + iep-border)
      #v(8pt)
      #text(weight: "bold", fill: iep-red)[Plan du tram :] distances et tracés sont déformés, mais les connexions deviennent immédiates.
      #v(10pt)
      #align(center)[
        #cetz.canvas(length: 0.85cm, {
          import cetz.draw: *
          // Ligne A (gris secondaire) : Merignac -> Quinconces -> Rive droite
          line((0.8, 2.0), (5.0, 1.3), (7.6, 2.1), stroke: 1.8pt + rgb("#cbd5e1"))
          // Ligne C (gris secondaire) : Gare -> Quinconces -> Lac
          line((5.0, 0.0), (5.0, 1.3), (5.0, 2.3), stroke: 1.8pt + iep-gray)
          // Ligne B (Rouge IEP) : Pessac -> Victoire -> Quinconces
          line((0, 0.2), (3.0, 0.2), (5.0, 1.3), (7.6, 1.3), stroke: 2.6pt + iep-red)

          // Stations
          circle((0.5, 0.2), radius: 0.14, fill: white, stroke: 2pt + iep-red)
          content((0.5, -0.27), text(size: 9.5pt, weight: "bold", fill: iep-anthracite)[Pessac / Campus])

          circle((3.0, 0.2), radius: 0.14, fill: white, stroke: 2pt + iep-red)
          content((3.0, -0.27), text(size: 9.5pt, fill: iep-anthracite)[Victoire])

          circle((5.0, 1.3), radius: 0.2, fill: white, stroke: 2.2pt + iep-anthracite)
          content((5.0, 0.72), text(size: 9.5pt, weight: "bold", fill: iep-anthracite)[Quinconces])

          content((0.9, 2.34), text(size: 9pt, weight: "bold", fill: iep-gray)[Ligne A])
          content((7.2, 1.64), text(size: 9pt, weight: "bold", fill: iep-red)[Ligne B])
          content((5.95, 2.26), text(size: 9pt, weight: "bold", fill: iep-gray)[Ligne C])
        })
      ]
    ],
  )
]

// ============================================================================
// Slide 5 : Qu'est-ce qu'un algorithme ?
// ============================================================================

#slide(
  category: "Fondations",
  title: "Qu'est-ce qu'un algorithme ?",
)[
  #grid(
    columns: (1fr, auto),
    gutter: 16pt,
    align: horizon,
    text(size: 13pt, fill: iep-anthracite)[
      Une #strong[suite finie d'instructions ordonnées] qui transforme des ingrédients de départ en un résultat précis : exactement comme une #strong[recette de pâte à crêpes].
    ],
    text(size: 11.5pt, weight: "bold", fill: iep-anthracite)[
      Ingrédients #h(5pt) #text(fill: iep-gray)[→] #h(5pt) Étapes #h(5pt) #text(fill: iep-gray)[→] #h(5pt) #text(fill: iep-red)[Crêpes]
    ],
  )

  #v(10pt)
  #line(length: 100%, stroke: 0.6pt + iep-border)
  #v(14pt)

  #grid(
    columns: (1fr, 1fr),
    gutter: 28pt,
    align: top,
    [
      #num-head("01", "Recette dictée à la main", accent: iep-gray)
      #v(10pt)
      #set text(size: 12pt)
      On écrit explicitement chaque règle logique :
      #v(8pt)
      #block(
        width: 100%,
        fill: iep-surface,
        inset: (x: 12pt, y: 9pt),
        [
          #text(size: 11pt, font: "DejaVu Sans Mono", fill: iep-anthracite)[
            si farine = 250 g et œufs = 3 : \
            #h(12pt) ajouter 50 cl de lait \
            sinon : ajuster la dose
          ]
        ],
      )
      #v(8pt)
      - #strong[Atout :] transparence totale.
      - #strong[Limite :] ingérable dès que des dizaines de facteurs interagissent.
    ],
    [
      #num-head("02", "Recette apprise par l'expérience", accent: iep-red)
      #v(10pt)
      #set text(size: 12pt)
      Principe du #strong[Machine Learning] : on ne dicte plus les règles.
      #v(8pt)
      #text(size: 12pt, style: "italic", fill: iep-anthracite)[
        On fait goûter #strong[1 000 crêpes déjà notées] à l'algorithme : il découvre seul quelles proportions produisent les meilleures notes.
      ]
      #v(12pt)
      - #strong[Atout :] capte des combinaisons complexes.
      - #strong[Enjeu :] la recette obtenue devient plus difficile à lire (ex. « goûter » `4 734` foyers réels d'ANES 2024 pour tracer la droite la plus fidèle).
    ],
  )
]

// ============================================================================
// Slide 6 : Supervisé vs Non supervisé
// ============================================================================

#slide(
  category: "Apprentissage automatique",
  title: "Supervisé vs Non supervisé",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 28pt,
    align: top,
    [
      #line(length: 100%, stroke: 1.5pt + iep-red)
      #v(8pt)
      #grid(
        columns: (1fr, auto),
        align: horizon,
        text(font: font-heading, size: 15pt, weight: "bold", fill: iep-anthracite)[
          Apprentissage supervisé
        ],
        text(size: 10pt, weight: "bold", fill: iep-red, tracking: 0.6pt)[CIBLE Y CONNUE],
      )
      #v(8pt)
      #set text(size: 12pt)
      On fournit à la machine des paires #strong[(profil X, réponse Y)] pour qu'elle apprenne à prédire #strong[Y] sur de nouveaux cas.
      #v(14pt)
      #align(center)[
        #diagram(
          spacing: (10mm, 6mm),
          node((0, 0), box(fill: iep-surface, stroke: 0.8pt + iep-gray, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: iep-anthracite)[Données X]], stroke: none, fill: none),
          node((1, 0), box(fill: white, stroke: 1pt + iep-anthracite, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: iep-anthracite)[Modèle]], stroke: none, fill: none),
          node((2, 0), box(fill: rgb("#fff5f5"), stroke: 1.2pt + iep-red, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: iep-red)[Revenu Y]], stroke: none, fill: none),
          edge((0, 0), (1, 0), "->", stroke: 1.2pt + iep-anthracite),
          edge((1, 0), (2, 0), "->", stroke: 1.2pt + iep-red),
        )
      ]
      #v(14pt)
      #line(length: 100%, stroke: 0.6pt + iep-border)
      #v(8pt)
      #text(size: 11.5pt, fill: iep-anthracite)[
        #strong[En sciences sociales :] prédire le #strong[revenu annuel du foyer] (`$ / an`) ou la participation électorale à partir de variables sociodémographiques.
      ]
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-gray)
      #v(8pt)
      #grid(
        columns: (1fr, auto),
        align: horizon,
        text(font: font-heading, size: 15pt, weight: "bold", fill: iep-anthracite)[
          Apprentissage non supervisé
        ],
        text(size: 10pt, weight: "bold", fill: iep-gray, tracking: 0.6pt)[AUCUN Y FOURNI],
      )
      #v(8pt)
      #set text(size: 12pt)
      Aucune étiquette à prédire : l'algorithme explore les données #strong[X] pour regrouper ce qui se ressemble.
      #v(12pt)
      #align(center)[
        #diagram(
          spacing: (10mm, 4mm),
          node((0, 0.5), box(fill: iep-surface, stroke: 0.8pt + iep-gray, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: iep-anthracite)[Données X]], stroke: none, fill: none),
          node((1, 0.5), box(fill: white, stroke: 1pt + iep-anthracite, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: iep-anthracite)[Regroupement]], stroke: none, fill: none),
          node((2, 0), box(fill: iep-surface, stroke: 0.8pt + iep-gray, radius: 3pt, inset: (x: 8pt, y: 3.5pt))[#text(size: 9.5pt, weight: "bold", fill: iep-anthracite)[Groupe A]], stroke: none, fill: none),
          node((2, 1), box(fill: iep-surface, stroke: 0.8pt + iep-gray, radius: 3pt, inset: (x: 8pt, y: 3.5pt))[#text(size: 9.5pt, weight: "bold", fill: iep-gray)[Groupe B]], stroke: none, fill: none),
          edge((0, 0.5), (1, 0.5), "->", stroke: 1.2pt + iep-anthracite),
          edge((1, 0.5), (2, 0), "->", stroke: 1pt + iep-anthracite),
          edge((1, 0.5), (2, 1), "->", stroke: 1pt + iep-gray),
        )
      ]
      #v(10pt)
      #line(length: 100%, stroke: 0.6pt + iep-border)
      #v(8pt)
      #text(size: 11.5pt, fill: iep-anthracite)[
        #strong[En sciences sociales :] regrouper des trajectoires ou profils socio-économiques similaires ou dégager des thèmes latents dans un corpus de discours.
      ]
    ],
  )
]

// ============================================================================
// Slide 7 : Section 02
// ============================================================================

#section-slide(
  num: "02",
  title: "De la boîte de verre à la boîte noire",
  subtitle: "Comparer la lisibilité des coefficients à la puissance des couches cachées",
  tag: "Partie 2 : Modélisation",
)

// ============================================================================
// Slide 8 : Un modèle boîte de verre : Y ~ X
// ============================================================================

#slide(
  category: "Régression simple (2 paramètres)",
  title: "Un modèle « boîte de verre » : Y ~ X",
)[
  #two-col(
    ratio: (1.14fr, 0.86fr),
    gutter: 24pt,
    [
      #align(center)[
        #cetz.canvas(length: 1.0cm, {
          import cetz.draw: *

          // Cadre du graphique : x de 7.5 a 20.5 ans -> [0, 7.28], y de 0 a 250 k$/an -> [0, 5.0]
          let map-x(ed) = (ed - 7.5) * 0.56
          let map-y(rev) = rev * 0.02

          // Grille legere horizontale
          for (val, lbl) in ((50, "50"), (100, "100"), (150, "150"), (200, "200"), (250, "250")) {
            line((0, map-y(val)), (7.4, map-y(val)), stroke: 0.4pt + iep-border)
            content((-0.44, map-y(val)), text(size: 8.5pt, fill: iep-gray)[#lbl])
          }
          content((-0.44, 0), text(size: 8.5pt, fill: iep-gray)[0])

          // Axes
          line((0, 0), (7.4, 0), stroke: 1pt + iep-anthracite)
          line((0, 0), (0, 5.3), stroke: 1pt + iep-anthracite)

          // Graduations X
          for ed in (8, 12, 16, 20) {
            line((map-x(ed), 0), (map-x(ed), -0.1), stroke: 0.8pt + iep-anthracite)
            content((map-x(ed), -0.35), text(size: 8.5pt, fill: iep-gray)[#ed])
          }

          // Points realistes ANES 2024 autour de y = -100.4 + 13.445 * etudes (sans chevauchement avec le triangle)
          let pts = (
            (8.0, 14.0), (8.0, 32.0), (8.5, 48.0), (9.0, 22.0), (9.0, 65.0),
            (10.0, 78.0), (10.5, 92.0), (11.0, 12.0), (11.5, 112.0),
            (12.0, 62.0), (12.0, 96.0), (12.0, 142.0), (13.0, 118.0),
            (13.0, 158.0), (14.0, 134.0), (14.0, 178.0), (14.5, 19.0),
            (15.0, 116.0), (15.5, 148.0), (16.0, 42.0), (16.0, 94.0),
            (16.0, 132.0), (16.0, 186.0), (17.0, 226.0), (17.0, 108.0),
            (17.5, 168.0), (18.0, 122.0), (18.0, 212.0), (19.0, 144.0),
            (19.5, 198.0), (20.0, 156.0), (20.0, 238.0),
          )
          for (rx, ry) in pts {
            circle((map-x(rx), map-y(ry)), radius: 0.08, fill: rgb("#cbd5e1"), stroke: 0.6pt + iep-gray)
          }

          // Droite OLS : y(8) = 7.16, y(20) = 168.50
          line((map-x(8.0), map-y(7.16)), (map-x(20.0), map-y(168.50)), stroke: 2.3pt + iep-red)

          // Triangle de pente (+4 ans -> +53.8 k$) de x=10 a x=14
          let x1 = 10.0
          let x2 = 14.0
          let y1 = -100.399 + 13.445 * x1
          let y2 = -100.399 + 13.445 * x2
          line((map-x(x1), map-y(y1)), (map-x(x2), map-y(y1)), stroke: (paint: iep-anthracite, thickness: 1.1pt, dash: "dashed"))
          line((map-x(x2), map-y(y1)), (map-x(x2), map-y(y2)), stroke: (paint: iep-red, thickness: 1.6pt))
          content((map-x(12.0), map-y(y1) - 0.34), text(size: 8.5pt, weight: "bold", fill: iep-anthracite)[+4 ans])
          content((map-x(x2) + 0.88, map-y((y1 + y2) / 2) - 0.02), text(size: 8.5pt, weight: "bold", fill: iep-red)[+53.8 k\$])

          // Etiquette droite
          content((map-x(11.6), map-y(228.0)), text(size: 9.2pt, weight: "bold", fill: iep-red)[ŷ = -100.4 + 13.4 × etudes (k\$)])

          // Titres axes
          content((3.7, -0.82), text(size: 9.5pt, weight: "bold", fill: iep-anthracite)[Années d'études (8 à 20 ans)])
          content((1.15, 5.65), text(size: 9.5pt, weight: "bold", fill: iep-anthracite)[Revenu annuel (k\$ / an)])
        })
      ]
    ],
    [
      #block(
        width: 100%,
        fill: iep-dark-bg,
        radius: 3pt,
        inset: (x: 12pt, y: 10pt),
        [
          #text(size: 9pt, weight: "bold", fill: rgb("#adb5bd"))[CODE PYTHON (OLS : MOINDRES CARRÉS)]
          #v(4pt)
          #text(size: 9.5pt, fill: white)[
            #raw("smf.ols(\"revenu_annuel ~ etudes\", data=df).fit()")
          ]
        ],
      )
      #v(14pt)
      #text(font: font-heading, size: 14pt, weight: "bold", fill: iep-anthracite)[
        Seulement 2 paramètres lisibles
      ]
      #v(6pt)
      #set text(size: 11.5pt)
      - #strong[Constante (`β0`) = `-100 399 $`] : niveau théorique à `etudes = 0` (extrapolation hors échantillon).
      - #strong[Pente `etudes` (`β1`) = #text(fill: iep-red)[`+13 445 $ / an`]] par année d'études : soit #strong[`+53 780 $`] (`+53.8 k$`) pour `+4` ans d'études (`p < 0.001`).

      #v(16pt)
      #line(length: 100%, stroke: 0.6pt + iep-border)
      #v(10pt)

      #grid(
        columns: (1fr, 1fr),
        gutter: 16pt,
        [
          #text(font: font-heading, size: 22pt, weight: "bold", fill: iep-anthracite)[0.18] \
          #text(size: 10.5pt, weight: "bold", fill: iep-anthracite)[Part expliquée (`R²`)] \
          #text(size: 9.5pt, fill: iep-gray)[Variance captée par `etudes`]
        ],
        [
          #text(font: font-heading, size: 20pt, weight: "bold", fill: iep-red)[70 289 \$ / an] \
          #text(size: 10.5pt, weight: "bold", fill: iep-anthracite)[Erreur moyenne (`RMSE`)] \
          #text(size: 9.5pt, fill: iep-gray)[Moyenne : 97 347 \$ / an]
        ],
      )
    ],
  )
]

// ============================================================================
// Slide 9 : Plusieurs leviers : le modèle de revenu (7 paramètres)
// ============================================================================

#slide(
  category: "Régression multiple",
  title: "Plusieurs leviers : le modèle de revenu (7 paramètres)",
)[
  #grid(
    columns: (1fr, auto),
    gutter: 14pt,
    align: horizon,
    block(fill: iep-dark-bg, radius: 3pt, inset: (x: 11pt, y: 6.5pt), width: 100%)[
      #text(size: 8.2pt, fill: white)[
        #raw("smf.ols(\"revenu_annuel ~ etudes + age + en_emploi + marie + femme + minorite\", data=df).fit()")
      ]
    ],
    [
      #text(size: 10.5pt, weight: "bold", fill: iep-anthracite)[7 paramètres]
      #h(6pt) #text(fill: iep-border)[|] #h(6pt)
      #text(size: 10.5pt, weight: "bold", fill: iep-red)[R² = 0.31]
      #h(6pt) #text(fill: iep-border)[|] #h(6pt)
      #text(size: 10.5pt, weight: "bold", fill: iep-anthracite)[RMSE = 64 267 \$]
    ],
  )

  #v(10pt)

  #set text(size: 10.4pt)
  #table(
    columns: (1.38fr, 0.92fr, 0.88fr, 1.82fr),
    inset: (x: 8pt, y: 5.5pt),
    stroke: (_, row) => (
      top: if row == 0 { 1.2pt + iep-anthracite } else { 0.4pt + iep-border },
      bottom: if row == 0 { 1.2pt + iep-anthracite } else if row == 7 { 1pt + iep-red } else { 0.4pt + iep-border },
      left: none,
      right: none,
    ),
    fill: (_, row) => if row in (6, 7) { rgb("#fff5f5") } else { white },
    align: (left, center, right, left),
    text(weight: "bold", fill: iep-anthracite)[Variable (`β0` + 6 leviers)],
    text(weight: "bold", fill: iep-anthracite)[Échelle (moyenne)],
    text(weight: "bold", fill: iep-anthracite)[Coefficient],
    text(weight: "bold", fill: iep-anthracite)[Interprétation et audit de biais],

    [#strong[Constante (`β0`)]], [Point de départ], [#strong[`-87 268 $`]], [Niveau de référence théorique avant ajout des leviers],
    [#strong[`etudes`]], [`6` à `20` ans (`14.7`)], [#text(weight: "bold", fill: iep-anthracite)[`+10 998 $ / an`]], [Rendement de chaque année d'études (`p < 0.001`)],
    [#strong[`age`]], [`18` à `80` ans (`52.7`)], [#text(weight: "bold", fill: iep-anthracite)[`-227 $ / an`]], [Pente linéaire moyenne sur l'âge adulte (`p < 0.001`)],
    [#strong[`en_emploi`]], [`0 / 1` (`68.8 %`)], [#text(weight: "bold", fill: iep-anthracite)[`+24 855 $ / an`]], [Prime liée à l'exercice d'un emploi (`p < 0.001`)],
    [#strong[`marie`]], [`0 / 1` (`51.6 %`)], [#text(weight: "bold", fill: iep-anthracite)[`+48 093 $ / an`]], [Effet foyer à deux revenus et statut marital (`p < 0.001`)],
    [#strong(text(fill: iep-red)[`femme`]) #text(size: 8.6pt, weight: "bold", fill: iep-red)[(Protégé : sexe)]], [`0 / 1` (`53.2 %`)], [#text(weight: "bold", fill: iep-red)[`-8 007 $ / an`]], [#text(fill: iep-red)[Écart significatif à profil égal (`p < 0.001`) : signal d'alerte]],
    [#strong(text(fill: iep-red)[`minorite`]) #text(size: 8.6pt, weight: "bold", fill: iep-red)[(Protégé : origine)]], [`0 / 1` (`27.5 %`)], [#text(weight: "bold", fill: iep-red)[`-10 328 $ / an`]], [#text(fill: iep-red)[Écart significatif à profil égal (`p < 0.001`) : signal d'alerte]],
  )

  #v(8pt)

  #block(
    width: 100%,
    stroke: (left: 2.5pt + iep-red),
    inset: (left: 12pt, y: 2pt),
    [
      #text(size: 10.4pt, fill: iep-anthracite)[
        #strong[Audit de biais :] à diplôme, âge, emploi et situation familiale identiques, les deux attributs protégés restent hautement significatifs (`femme` : #strong(text(fill: iep-red)[-8 007 \$]), `minorite` : #strong(text(fill: iep-red)[-10 328 \$]), `p < 0.001`). Dans un scoring équitable (crédit, RH), sexe et origine doivent être audités et neutralisés.
      ]
    ],
  )
]

// ============================================================================
// Slide 10 : Démo en direct : Workshop IA Explicable (5 onglets)
// ============================================================================

#slide(
  category: "Démonstration interactive (ANES 2024)",
  title: "Démo en direct : Workshop IA Explicable (XAI)",
)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 24pt,
    align: top,
    [
      #line(length: 100%, stroke: 1.5pt + iep-gray)
      #v(8pt)
      #grid(
        columns: (auto, 1fr),
        gutter: 10pt,
        align: horizon,
        text(font: font-heading, size: 22pt, weight: "bold", fill: iep-gray)[02],
        text(size: 10pt, weight: "bold", fill: iep-gray, tracking: 0.8pt)[ONGLET 2],
      )
      #v(8pt)
      #text(font: font-heading, size: 14.5pt, weight: "bold", fill: iep-anthracite)[
        Un paramètre
      ]
      #v(8pt)
      #set text(size: 11.2pt)
      - Observer `Y ~ X` sur #strong[100 points réels `ANES 2024`] (`-128.8 k$ + 15.2 k$ × etudes`, `RMSE = 70 237 $`, axe de `0` à `20` ans) avec #strong[résidus sur tous les points].
      - #strong[Cliquer] pour ajouter un profil extrême et voir la droite basculer en direct.
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-anthracite)
      #v(8pt)
      #grid(
        columns: (auto, 1fr),
        gutter: 10pt,
        align: horizon,
        text(font: font-heading, size: 22pt, weight: "bold", fill: iep-anthracite)[03],
        text(size: 10pt, weight: "bold", fill: iep-anthracite, tracking: 0.8pt)[ONGLET 3],
      )
      #v(8pt)
      #text(font: font-heading, size: 14.5pt, weight: "bold", fill: iep-anthracite)[
        Quelques paramètres
      ]
      #v(8pt)
      #set text(size: 11.2pt)
      - Régler les #strong[6 leviers] (dont les attributs protégés `femme` et `minorite`) pour construire un profil de foyer.
      - Lire chaque contribution en #strong[`$ / an`] autour de la moyenne (`97 347 $ / an`) qui forme le revenu prédit.
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-red)
      #v(8pt)
      #grid(
        columns: (auto, 1fr),
        gutter: 10pt,
        align: horizon,
        text(font: font-heading, size: 22pt, weight: "bold", fill: iep-red)[04],
        text(size: 10pt, weight: "bold", fill: iep-red, tracking: 0.8pt)[ONGLET 4],
      )
      #v(8pt)
      #text(font: font-heading, size: 14.5pt, weight: "bold", fill: iep-anthracite)[
        Le Deep Learning
      ]
      #v(8pt)
      #set text(size: 11.2pt)
      - Passer de la régression (`7` paramètres) à la #strong[boîte noire] via le #strong[réseau de neurones interactif] (`329` paramètres, `R² = 0.34`).
      - Lancer des #strong[sondes locales] (effets autour d'un profil, scénarios « et si... ? ») quand les poids deviennent opaques.
    ],
  )

  #v(18pt)

  #callout-strip(
    "Navigation (5 onglets)",
    [
      #strong[Onglet 1 (Introduction) :] modèle, algorithme, XAI. #strong[Onglets 2, 3 et 4 :] mêmes données `ANES 2024`, seule change l'architecture. #strong[Onglet 5 (Hack-time) :] accès direct au notebook #strong[Google Colab].
    ],
    accent: iep-red,
  )
]

// ============================================================================
// Slide 11 : Entrer dans le Deep Learning
// ============================================================================

#slide(
  category: "Réseaux de neurones",
  title: "Entrer dans le Deep Learning",
)[
  #two-col(
    ratio: (1.30fr, 0.90fr),
    gutter: 24pt,
    [
      #align(center)[
        #diagram(
          spacing: (7.2mm, 6.8mm),
          node-stroke: 1pt,

          // En-tetes des couches
          node((1, -0.65), text(size: 8pt, weight: "bold", fill: iep-anthracite)[ENTRÉES (6)], stroke: none, fill: none),
          node((2, -0.65), text(size: 8pt, weight: "bold", fill: iep-gray)[COUCHE 1 (16)], stroke: none, fill: none),
          node((3, -0.65), text(size: 8pt, weight: "bold", fill: iep-gray)[COUCHE 2 (12)], stroke: none, fill: none),
          node((4, -0.65), text(size: 8pt, weight: "bold", fill: iep-red)[SORTIE (1)], stroke: none, fill: none),

          // Etiquettes des 6 variables ANES 2024 (colonne 0)
          node((0, 0.0), align(right)[#text(size: 8pt, weight: "bold", fill: iep-anthracite)[etudes]], stroke: none, fill: none),
          node((0, 0.78), align(right)[#text(size: 8pt, weight: "bold", fill: iep-anthracite)[age]], stroke: none, fill: none),
          node((0, 1.56), align(right)[#text(size: 8pt, weight: "bold", fill: iep-anthracite)[en_emploi]], stroke: none, fill: none),
          node((0, 2.34), align(right)[#text(size: 8pt, weight: "bold", fill: iep-anthracite)[marie]], stroke: none, fill: none),
          node((0, 3.12), align(right)[#text(size: 8pt, weight: "bold", fill: iep-red)[femme]], stroke: none, fill: none),
          node((0, 3.90), align(right)[#text(size: 8pt, weight: "bold", fill: iep-red)[minorite]], stroke: none, fill: none),

          // Couche entree (colonne 1)
          for i in range(6) {
            let col = if i >= 4 { iep-red } else { iep-anthracite }
            let bg = if i >= 4 { rgb("#fff5f5") } else { iep-surface }
            node((1, i * 0.78), text(size: 7.8pt, weight: "bold", fill: col)[$x_#(i + 1)$],
              shape: "circle", radius: 3.3mm, fill: bg, stroke: 1.3pt + col)
          },

          // Couche cachee 1 (colonne 2 : 4 neurones representatifs + ellipse)
          for j in (0.4, 1.35, 2.55, 3.5) {
            node((2, j), [], shape: "circle", radius: 3.1mm, fill: iep-surface, stroke: 1.1pt + iep-gray)
          },
          node((2, 1.95), text(size: 10pt, weight: "bold", fill: iep-gray)[⋮], stroke: none, fill: none),

          // Couche cachee 2 (colonne 3 : 3 neurones representatifs + ellipse)
          for k in (0.75, 1.95, 3.15) {
            node((3, k), [], shape: "circle", radius: 3.1mm, fill: iep-surface, stroke: 1.1pt + iep-gray)
          },
          node((3, 1.35), text(size: 10pt, weight: "bold", fill: iep-gray)[⋮], stroke: none, fill: none),

          // Sortie (colonne 4) et etiquette (colonne 5)
          node((4, 1.95), text(size: 9pt, weight: "bold", fill: iep-red)[$hat(y)$],
            shape: "circle", radius: 4.2mm, fill: rgb("#fff5f5"), stroke: 1.8pt + iep-red),
          node((5, 1.95), align(left)[#text(size: 8pt, weight: "bold", fill: iep-red)[Revenu \ prédit]], stroke: none, fill: none),

          // Connexions Entree -> Couche 1
          for i in range(6) {
            for j in (0.4, 1.35, 2.55, 3.5) {
              let lcol = if i >= 4 { iep-red.lighten(60%) } else { rgb("#cbd5e1") }
              edge((1, i * 0.78), (2, j), stroke: 0.45pt + lcol)
            }
          },

          // Connexions Couche 1 -> Couche 2
          for j in (0.4, 1.35, 2.55, 3.5) {
            for k in (0.75, 1.95, 3.15) {
              edge((2, j), (3, k), stroke: 0.5pt + rgb("#94a3b8"))
            }
          },

          // Connexions Couche 2 -> Sortie
          for k in (0.75, 1.95, 3.15) {
            edge((3, k), (4, 1.95), "->", stroke: 0.85pt + iep-red.lighten(30%))
          },
        )
      ]
      #v(8pt)
      #line(length: 100%, stroke: 0.6pt + iep-border)
      #v(6pt)
      #grid(
        columns: (1fr, auto),
        align: horizon,
        text(size: 9.2pt, style: "italic", fill: iep-gray)[
          Réseau multicouche (MLP : 6 → 16 → 12 → 1)
        ],
        text(size: 9.6pt, weight: "bold", fill: iep-red)[
          329 paramètres | R² = 0.34 | RMSE = 62 837 \$
        ],
      )
    ],
    [
      #text(font: font-heading, size: 13.5pt, weight: "bold", fill: iep-anthracite)[
        1. Courbe non linéaire de l'âge
      ]
      #v(5pt)
      #set text(size: 11.2pt)
      Sur `ANES 2024`, l'OLS résume mal la hausse de carrière puis la baisse à la retraite avec une pente plate (`-227 $ / an`). Le MLP capte cette bosse courbe et fait monter `R²` de `0.31` à `0.34`.

      #v(12pt)
      #line(length: 100%, stroke: 0.6pt + iep-border)
      #v(10pt)

      #text(font: font-heading, size: 13.5pt, weight: "bold", fill: iep-anthracite)[
        2. Poids partagés & variables proxy
      ]
      #v(5pt)
      #set text(size: 11.2pt)
      Chaque entrée irrigue les #strong[16] puis #strong[12 neurones] : aucun poids isolé ne donne un effet clair. Même sans `femme` ou `minorite`, `etudes`, `marie` et `en_emploi` en portent la trace indirecte.

      #v(14pt)

      #block(
        width: 100%,
        fill: iep-surface,
        stroke: (left: 3pt + iep-red),
        inset: (x: 12pt, y: 8pt),
        [
          #text(size: 11pt, weight: "bold", fill: iep-red)[Résultat :]
          #text(size: 11pt, fill: iep-anthracite)[ on gagne en flexibilité (`R²` de `0.31` à `0.34`, `RMSE` à `62 837 $ / an`), mais on perd la lecture directe.]
        ],
      )
    ],
  )
]

// ============================================================================
// Slide 12 : L'explosion des paramètres : de 2 à 1 000 milliards
// ============================================================================

#slide(
  category: "Changement d'échelle",
  title: "L'explosion des paramètres : de 2 à 1 000 milliards",
)[
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    gutter: 20pt,
    align: top,
    [
      #line(length: 100%, stroke: 1.5pt + rgb("#cbd5e1"))
      #v(8pt)
      #text(size: 9.5pt, weight: "bold", fill: iep-gray, tracking: 0.8pt)[PALIER 01]
      #v(4pt)
      #box(height: 28pt, align(bottom, text(font: font-heading, size: 24pt, weight: "bold", fill: iep-gray)[2])) \
      #text(size: 11pt, weight: "bold", fill: iep-anthracite)[paramètres]
      #v(8pt)
      #line(length: 100%, stroke: 0.5pt + iep-border)
      #v(8pt)
      #set text(size: 10.8pt)
      #strong[OLS simple] (`Y ~ X`)
      #v(4pt)
      - `R² = 0.18`
      - `RMSE = 70.3 k$`
      - #strong[Lisibilité :] totale (1 pente).
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-gray)
      #v(8pt)
      #text(size: 9.5pt, weight: "bold", fill: iep-gray, tracking: 0.8pt)[PALIER 02]
      #v(4pt)
      #box(height: 28pt, align(bottom, text(font: font-heading, size: 24pt, weight: "bold", fill: iep-anthracite)[7])) \
      #text(size: 11pt, weight: "bold", fill: iep-anthracite)[paramètres]
      #v(8pt)
      #line(length: 100%, stroke: 0.5pt + iep-border)
      #v(8pt)
      #set text(size: 10.8pt)
      #strong[OLS complet] (`6` leviers)
      #v(4pt)
      - `R² = 0.31`
      - `RMSE = 64.3 k$`
      - #strong[Lisibilité :] totale (additif).
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-anthracite)
      #v(8pt)
      #text(size: 9.5pt, weight: "bold", fill: iep-anthracite, tracking: 0.8pt)[PALIER 03]
      #v(4pt)
      #box(height: 28pt, align(bottom, text(font: font-heading, size: 24pt, weight: "bold", fill: iep-anthracite)[329])) \
      #text(size: 11pt, weight: "bold", fill: iep-anthracite)[paramètres]
      #v(8pt)
      #line(length: 100%, stroke: 0.5pt + iep-border)
      #v(8pt)
      #set text(size: 10.8pt)
      #strong[Petit MLP] (`2` couches)
      #v(4pt)
      - `R² = 0.34`
      - `RMSE = 62.8 k$`
      - #strong[Lisibilité :] opaque (poids mêlés).
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-red)
      #v(8pt)
      #text(size: 9.5pt, weight: "bold", fill: iep-red, tracking: 0.8pt)[PALIER 04]
      #v(4pt)
      #box(height: 28pt, align(bottom, text(font: font-heading, size: 15.5pt, weight: "bold", fill: iep-red)[70 Md à 1 000+ Md])) \
      #text(size: 11pt, weight: "bold", fill: iep-anthracite)[paramètres]
      #v(8pt)
      #line(length: 100%, stroke: 0.5pt + iep-border)
      #v(8pt)
      #set text(size: 10.8pt)
      #strong[Grands modèles (LLM)]
      #v(4pt)
      - Même empilement appliqué au texte
      - #strong[Lisibilité :] boîte noire totale sur les poids.
    ],
  )

  #v(24pt)

  #grid(
    columns: (auto, 1fr, auto),
    gutter: 14pt,
    align: horizon,
    text(size: 11pt, weight: "bold", fill: iep-gray)[Lisibilité maximale],
    box(
      width: 100%,
      height: 7pt,
      radius: 3.5pt,
      fill: gradient.linear(rgb("#e2e8f0"), iep-gray, iep-anthracite, iep-red),
    ),
    text(size: 11pt, weight: "bold", fill: iep-red)[Capacité maximale / Opacité],
  )
  #v(8pt)
  #align(center, text(size: 11.5pt, fill: iep-anthracite)[
    Plus le nombre de paramètres croît, plus la prédiction devient performante, mais plus il devient impossible d'expliquer le résultat par simple lecture des poids.
  ])
]

// ============================================================================
// Slide 13 : Qu'est-ce que l'IA Explicable (XAI) ?
// ============================================================================

#slide(
  category: "Explicabilité",
  title: "Qu'est-ce que l'IA Explicable (XAI) ?",
)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 28pt,
    align: top,
    [
      #num-head("01", "Explicabilité intrinsèque", accent: iep-gray)
      #v(4pt)
      #text(size: 10.5pt, weight: "bold", fill: iep-gray)[Approche « boîte de verre »]
      #v(10pt)
      #set text(size: 11.8pt)
      - Le modèle est #strong[lisible par construction] : régression linéaire, régression logistique, arbre de décision peu profond.
      - Les paramètres du modèle sont #strong[directement l'explication].
      - Pas besoin de méthode secondaire : on lit la formule et les signes.
    ],
    [
      #num-head("02", "Explicabilité post-hoc", accent: iep-red)
      #v(4pt)
      #text(size: 10.5pt, weight: "bold", fill: iep-red)[Sondes sur une « boîte noire »]
      #v(10pt)
      #set text(size: 11.8pt)
      - #strong[Perturbations locales (SHAP, LIME) :] on fait bouger chaque variable autour d'un individu pour estimer son poids local.
      - #strong[Contrefactuels :] #emph[« Que faudrait-il modifier dans ce foyer pour que la prédiction change ? »]
      - #strong[Mise en récit par LLM :] traduire les scores en phrase claire.
    ],
  )

  #v(20pt)

  #callout-strip(
    "Vigilance & AI Act",
    [
      Une explication post-hoc (SHAP, LIME) est une #strong[approximation locale] qui ne prouve #strong[jamais une causalité]. Sur de vraies données d'enquête (`ANES 2024`) comme dans les systèmes à haut risque (crédit, recrutement, #strong[AI Act européen]), l'XAI sert à auditer les biais (`femme`, `minorite`) et leurs #strong[variables proxy].
    ],
    accent: iep-red,
  )
]

// ============================================================================
// Slide 14 : Section 03
// ============================================================================

#section-slide(
  num: "03",
  title: "Atelier pratique : Construire un profil de revenu",
  subtitle: "Observer les leviers en direct, puis ouvrir le code Python",
  tag: "Partie 3 : Mise en pratique",
)

// ============================================================================
// Slide 15 : Votre mission (15-20 min)
// ============================================================================

#slide(
  category: "Passer à l'action",
  title: "Votre mission (15 à 20 min)",
)[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 24pt,
    align: top,
    [
      #line(length: 100%, stroke: 1.5pt + iep-gray)
      #v(8pt)
      #text(font: font-heading, size: 22pt, weight: "bold", fill: iep-gray)[01]
      #v(6pt)
      #text(font: font-heading, size: 14.5pt, weight: "bold", fill: iep-anthracite)[
        Tester le clic & les résidus
      ]
      #v(8pt)
      #set text(size: 11pt)
      - Sur l'#strong[Onglet 2] (`Un paramètre`, `100` points réels `ANES 2024`), cochez #emph[Afficher les erreurs], puis ajoutez un point extrême au clic.
      - Testez `femme` et `minorite` sur les #strong[Onglets 3 et 4] (`7` vs `329` paramètres).
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-anthracite)
      #v(8pt)
      #text(font: font-heading, size: 22pt, weight: "bold", fill: iep-anthracite)[02]
      #v(6pt)
      #text(font: font-heading, size: 14.5pt, weight: "bold", fill: iep-anthracite)[
        Exécuter `smf.ols` sur Colab
      ]
      #v(8pt)
      #set text(size: 11pt)
      - Depuis l'#strong[Onglet 5] (`Hack-time`), ouvrez le #link("https://colab.research.google.com/github/mickaeltemporao/workshop-xai/blob/main/notebooks/atelier-xai-citoyen.ipynb")[#strong(text(fill: iep-red)[notebook Google Colab])] (dépôt #link("https://github.com/mickaeltemporao/workshop-xai")[GitHub]).
      - Chargez `ANES 2024` et retrouvez `R² = 0.31`, `femme` (`-8 007 $`) et `minorite` (`-10 328 $`).
    ],
    [
      #line(length: 100%, stroke: 1.5pt + iep-red)
      #v(8pt)
      #text(font: font-heading, size: 22pt, weight: "bold", fill: iep-red)[03]
      #v(6pt)
      #text(font: font-heading, size: 14.5pt, weight: "bold", fill: iep-anthracite)[
        Comparer `7` vs `329` paramètres
      ]
      #v(8pt)
      #set text(size: 11pt)
      - Basculez un attribut protégé (`femme`, `minorite`) puis variez une variable $X_i$ à la fois.
      - Confrontez boîte de verre (`7` params) et boîte noire (`329` params) sur des profils contrastés.
    ],
  )

  #v(14pt)

  #callout-strip(
    "Question fil rouge",
    [
      Comment évolue l'effet de l'`age` à `30` ans vs `70` ans dans la boîte noire (`329` paramètres) face au `-227 $ / an` fixe de la régression ?
    ],
    accent: iep-red,
  )

  #v(10pt)
  #align(left, text(size: 8.8pt, fill: iep-gray)[
    Note IA : supports et code conçus avec l'assistance d'outils d'IA générative, relus et validés par l'intervenant.
  ])
]

// ============================================================================
// Slide 16 : Page de clôture
// ============================================================================

#closing-slide()
