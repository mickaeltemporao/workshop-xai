#import "@preview/typslides:1.3.0": *
#import "@preview/cetz:0.4.2" as cetz
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// Configuration Typslides (monochrome darky + Fira Sans)
#show: typslides.with(
  ratio: "16-9",
  theme: "darky",
  font: "Fira Sans",
  font-size: 18pt,
  link-style: "both",
  show-progress: true,
)

// ============================================================================
// Helpers locaux minimalistes (monochrome + rouge d'accent)
// ============================================================================

#let accent-red = rgb("#dd1019")
#let ink = rgb("#202020")
#let muted = rgb("#64748b")
#let border-col = rgb("#cbd5e1")
#let surface = rgb("#f6f7f9")
#let dark-bg = rgb("#1f2328")

#let wslide(title: none, body) = slide(title: title)[
  #set text(size: 13pt, fill: ink)
  #set par(justify: false, leading: 0.65em)
  #set list(marker: text(fill: accent-red, weight: "bold")[•], spacing: 0.75em)
  #body
]

#let top-cols(columns: none, gutter: 1.8em, ..bodies) = grid(
  columns: columns,
  gutter: gutter,
  align: top,
  ..bodies,
)

#let num-head(num, title, accent: ink) = [
  #line(length: 100%, stroke: 1.5pt + accent)
  #v(7pt)
  #grid(
    columns: (auto, 1fr),
    gutter: 10pt,
    align: horizon,
    text(size: 20pt, weight: "bold", fill: accent)[#num],
    text(size: 15pt, weight: "bold", fill: ink)[#title],
  )
]

#let callout-strip(label, body, accent: accent-red) = block(
  width: 100%,
  fill: surface,
  stroke: (left: 3pt + accent),
  inset: (x: 14pt, y: 9pt),
  [
    #grid(
      columns: (auto, 1fr),
      gutter: 12pt,
      align: horizon,
      text(size: 10pt, weight: "bold", fill: accent, tracking: 0.8pt)[#upper(label)],
      text(size: 12pt, fill: ink)[#body],
    )
  ],
)

// ============================================================================
// Slide 1 : Page de titre
// ============================================================================

#front-slide(
  title: "Workshop IA Explicable (XAI)",
  subtitle: [De la régression aux grands modèles de langage],
  authors: "Mickael Temporão",
  info: [
    Sciences Po Bordeaux | Centre Émile Durkheim | 2026 \
    #link("https://mickaeltemporao.github.io/workshop-xai/")[mickaeltemporao.github.io/workshop-xai]
  ],
)

// ============================================================================
// Slide 2 : Feuille de route
// ============================================================================

#wslide(title: "Feuille de route de l'atelier")[
  #top-cols(columns: (1fr, 1fr), gutter: 2.2em)[
    #num-head("01", "Comprendre (15 à 20 min)", accent: ink)
    #v(10pt)
    - *Modèles et algorithmes* : simplifier le réel et apprendre par l'exemple.
    - *De la boîte de verre à la boîte noire* : comparer une régression lisible (`2` puis `7` paramètres) à un réseau de neurones (`329` paramètres) et aux LLM.
    - *IA Explicable (XAI)* : comment interroger un modèle devenu opaque, auditer les biais et éviter les pièges causaux.
  ][
    #num-head("02", "Pratiquer (15 à 20 min)", accent: accent-red)
    #v(10pt)
    - *Application interactive* : manipuler en direct le « Workshop IA Explicable (XAI) » (`100` points réels cliquables, `6` variables socio-économiques).
    - *Google Colab* : exécuter pas à pas une régression en Python (`statsmodels`) sans prérequis technique.
    - *Expérimentation* : faire varier un paramètre à la fois, explorer l'audit de biais et comparer boîte de verre et boîte noire.
  ]

  #v(16pt)

  #callout-strip(
    "Fil rouge",
    [
      *Étudier est-il vraiment utile ?* À partir de données réelles d'enquête (`4 734` foyers), mesurer l'effet d'une année d'études supplémentaire sur le revenu annuel, puis comparer différents modèles jusqu'à l'IA explicable.
    ],
    accent: accent-red,
  )
]

// ============================================================================
// Slide 3 : Section 01
// ============================================================================

#title-slide[
  01 · Modèles, algorithmes et apprentissage
]

// ============================================================================
// Slide 4 : Qu'est-ce qu'un modèle ?
// ============================================================================

#wslide(title: "Qu'est-ce qu'un modèle ?")[
  #top-cols(columns: (1fr, 1fr), gutter: 2.2em)[
    #text(size: 15.5pt, weight: "bold", fill: ink)[Une simplification utile du réel]
    #v(8pt)
    Un modèle n'est pas une copie exacte du monde : c'est une *heuristique* (une représentation simplifiée pour s'orienter) qui retient l'essentiel et met de côté le bruit.
    #v(8pt)
    - *Ce qu'on retire* rend la représentation lisible.
    - *Ce qu'on garde* dépend de la question posée.
    - En sciences sociales, modéliser aide à résumer des tendances collectives sans prétendre épuiser chaque parcours individuel.

    #v(14pt)

    #block(
      width: 100%,
      fill: surface,
      stroke: (left: 3pt + accent-red),
      inset: (x: 14pt, y: 10pt),
      [
        #text(size: 13.5pt, style: "italic", fill: ink)[
          « All models are wrong, but some are useful. »
        ]
        #v(4pt)
        #align(right, text(size: 11pt, weight: "bold", fill: accent-red)[
          George E. P. Box (1976)
        ])
      ],
    )
  ][
    #text(size: 15.5pt, weight: "bold", fill: ink)[Photo satellite vs plan du tram de Bordeaux]
    #v(8pt)
    #set text(size: 12pt)
    #text(weight: "bold", fill: muted)[Photo satellite :] fidèle au mètre près (toits, arbres, ruelles), mais inutilisable pour trouver sa correspondance en 5 secondes.
    #v(7pt)
    #line(length: 100%, stroke: 0.6pt + border-col)
    #v(7pt)
    #text(weight: "bold", fill: accent-red)[Plan du tram :] distances et tracés sont déformés, mais les connexions deviennent immédiates.
    #v(10pt)
    #align(center)[
      #cetz.canvas(length: 0.85cm, {
        import cetz.draw: *
        line((0.8, 2.0), (5.0, 1.3), (7.6, 2.1), stroke: 1.8pt + border-col)
        line((5.0, 0.0), (5.0, 1.3), (5.0, 2.3), stroke: 1.8pt + muted)
        line((0, 0.2), (3.0, 0.2), (5.0, 1.3), (7.6, 1.3), stroke: 2.6pt + accent-red)

        circle((0.5, 0.2), radius: 0.14, fill: white, stroke: 2pt + accent-red)
        content((0.5, -0.27), text(size: 9.5pt, weight: "bold", fill: ink)[Pessac / Campus])

        circle((3.0, 0.2), radius: 0.14, fill: white, stroke: 2pt + accent-red)
        content((3.0, -0.27), text(size: 9.5pt, fill: ink)[Victoire])

        circle((5.0, 1.3), radius: 0.2, fill: white, stroke: 2.2pt + ink)
        content((5.0, 0.72), text(size: 9.5pt, weight: "bold", fill: ink)[Quinconces])

        content((0.9, 2.34), text(size: 9pt, weight: "bold", fill: muted)[Ligne A])
        content((7.2, 1.64), text(size: 9pt, weight: "bold", fill: accent-red)[Ligne B])
        content((5.95, 2.26), text(size: 9pt, weight: "bold", fill: muted)[Ligne C])
      })
    ]
  ]
]

// ============================================================================
// Slide 5 : Qu'est-ce qu'un algorithme ?
// ============================================================================

#wslide(title: "Qu'est-ce qu'un algorithme ?")[
  #grid(
    columns: (1fr, auto),
    gutter: 16pt,
    align: horizon,
    text(size: 13.5pt, fill: ink)[
      Une *suite finie d'instructions ordonnées* qui transforme des ingrédients de départ en un résultat précis : exactement comme une *recette de pâte à crêpes*.
    ],
    text(size: 12pt, weight: "bold", fill: ink)[
      Ingrédients #h(5pt) #text(fill: muted)[→] #h(5pt) Étapes #h(5pt) #text(fill: muted)[→] #h(5pt) #text(fill: accent-red)[Crêpes]
    ],
  )

  #v(8pt)
  #line(length: 100%, stroke: 0.6pt + border-col)
  #v(12pt)

  #top-cols(columns: (1fr, 1fr), gutter: 2.2em)[
    #num-head("01", "Recette dictée à la main", accent: muted)
    #v(10pt)
    On écrit explicitement chaque règle logique :
    #v(8pt)
    #block(
      width: 100%,
      fill: surface,
      inset: (x: 12pt, y: 9pt),
      [
        #text(size: 11pt, font: "DejaVu Sans Mono", fill: ink)[
          si farine = 250 g et œufs = 3 : \
          #h(12pt) ajouter 50 cl de lait \
          sinon : ajuster la dose
        ]
      ],
    )
    #v(8pt)
    - *Atout :* transparence totale.
    - *Limite :* ingérable dès que des dizaines de facteurs interagissent.
  ][
    #num-head("02", "Recette apprise par l'expérience", accent: accent-red)
    #v(10pt)
    Principe du *Machine Learning* : on ne dicte plus les règles.
    #v(8pt)
    #text(size: 12.5pt, style: "italic", fill: ink)[
      On fait goûter *1 000 crêpes déjà notées* à l'algorithme : il découvre seul quelles proportions produisent les meilleures notes.
    ]
    #v(12pt)
    - *Atout :* capte des combinaisons complexes.
    - *Enjeu :* la recette obtenue devient plus difficile à lire (ex. « goûter » `4 734` foyers réels pour tracer la droite la plus fidèle).
  ]
]

// ============================================================================
// Slide 6 : Supervisé vs Non supervisé
// ============================================================================

#wslide(title: "Supervisé vs Non supervisé")[
  #top-cols(columns: (1fr, 1fr), gutter: 2.2em)[
    #line(length: 100%, stroke: 1.5pt + accent-red)
    #v(8pt)
    #grid(
      columns: (1fr, auto),
      align: horizon,
      text(size: 15.5pt, weight: "bold", fill: ink)[Apprentissage supervisé],
      text(size: 10pt, weight: "bold", fill: accent-red, tracking: 0.6pt)[CIBLE Y CONNUE],
    )
    #v(8pt)
    On fournit à la machine des paires *(profil X, réponse Y)* pour qu'elle apprenne à prédire *Y* sur de nouveaux cas.
    #v(14pt)
    #align(center)[
      #diagram(
        spacing: (10mm, 6mm),
        node((0, 0), box(fill: surface, stroke: 0.8pt + muted, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: ink)[Données X]], stroke: none, fill: none),
        node((1, 0), box(fill: white, stroke: 1pt + ink, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: ink)[Modèle]], stroke: none, fill: none),
        node((2, 0), box(fill: rgb("#fff5f5"), stroke: 1.2pt + accent-red, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: accent-red)[Revenu Y]], stroke: none, fill: none),
        edge((0, 0), (1, 0), "->", stroke: 1.2pt + ink),
        edge((1, 0), (2, 0), "->", stroke: 1.2pt + accent-red),
      )
    ]
    #v(14pt)
    #line(length: 100%, stroke: 0.6pt + border-col)
    #v(8pt)
    #text(size: 12pt, fill: ink)[
      *En sciences sociales :* prédire le *revenu annuel du foyer* (`$ / an`) ou la participation électorale à partir de variables sociodémographiques.
    ]
  ][
    #line(length: 100%, stroke: 1.5pt + muted)
    #v(8pt)
    #grid(
      columns: (1fr, auto),
      align: horizon,
      text(size: 15.5pt, weight: "bold", fill: ink)[Apprentissage non supervisé],
      text(size: 10pt, weight: "bold", fill: muted, tracking: 0.6pt)[AUCUN Y FOURNI],
    )
    #v(8pt)
    Aucune étiquette à prédire : l'algorithme explore les données *X* pour regrouper ce qui se ressemble.
    #v(12pt)
    #align(center)[
      #diagram(
        spacing: (10mm, 4mm),
        node((0, 0.5), box(fill: surface, stroke: 0.8pt + muted, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: ink)[Données X]], stroke: none, fill: none),
        node((1, 0.5), box(fill: white, stroke: 1pt + ink, radius: 3pt, inset: (x: 9pt, y: 5pt))[#text(size: 10pt, weight: "bold", fill: ink)[Regroupement]], stroke: none, fill: none),
        node((2, 0), box(fill: surface, stroke: 0.8pt + muted, radius: 3pt, inset: (x: 8pt, y: 3.5pt))[#text(size: 9.5pt, weight: "bold", fill: ink)[Groupe A]], stroke: none, fill: none),
        node((2, 1), box(fill: surface, stroke: 0.8pt + muted, radius: 3pt, inset: (x: 8pt, y: 3.5pt))[#text(size: 9.5pt, weight: "bold", fill: muted)[Groupe B]], stroke: none, fill: none),
        edge((0, 0.5), (1, 0.5), "->", stroke: 1.2pt + ink),
        edge((1, 0.5), (2, 0), "->", stroke: 1pt + ink),
        edge((1, 0.5), (2, 1), "->", stroke: 1pt + muted),
      )
    ]
    #v(10pt)
    #line(length: 100%, stroke: 0.6pt + border-col)
    #v(8pt)
    #text(size: 12pt, fill: ink)[
      *En sciences sociales :* regrouper des trajectoires ou profils socio-économiques similaires ou dégager des thèmes latents dans un corpus de discours.
    ]
  ]
]

// ============================================================================
// Slide 7 : Section 02
// ============================================================================

#title-slide[
  02 · De la boîte de verre à la boîte noire
]

// ============================================================================
// Slide 8 : Un modèle boîte de verre : Y ~ X
// ============================================================================

#wslide(title: "Un modèle « boîte de verre » : Y ~ X")[
  #cols(columns: (1.14fr, 0.86fr), gutter: 2em)[
    #align(center)[
      #cetz.canvas(length: 1.0cm, {
        import cetz.draw: *

        // Cadre : x de 0 a 20.5 ans -> [0, 7.38], y de 0 a 250 k$/an -> [0, 5.0]
        let map-x(ed) = ed * 0.36
        let map-y(rev) = rev * 0.02

        for (val, lbl) in ((50, "50"), (100, "100"), (150, "150"), (200, "200"), (250, "250")) {
          line((0, map-y(val)), (7.4, map-y(val)), stroke: 0.4pt + border-col)
          content((-0.44, map-y(val)), text(size: 8.5pt, fill: muted)[#lbl])
        }
        content((-0.44, 0), text(size: 8.5pt, fill: muted)[0])

        line((0, 0), (7.4, 0), stroke: 1pt + ink)
        line((0, 0), (0, 5.3), stroke: 1pt + ink)

        for ed in (0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20) {
          line((map-x(ed), 0), (map-x(ed), -0.1), stroke: 0.8pt + ink)
          content((map-x(ed), -0.35), text(size: 8pt, fill: muted)[#ed])
        }

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
          circle((map-x(rx), map-y(ry)), radius: 0.08, fill: rgb("#cbd5e1"), stroke: 0.6pt + muted)
        }

        line((map-x(7.47), map-y(0.0)), (map-x(20.0), map-y(168.50)), stroke: 2.3pt + accent-red)

        let x1 = 12.0
        let x2 = 16.0
        let y1 = -100.399 + 13.445 * x1
        let y2 = -100.399 + 13.445 * x2
        line((map-x(x1), map-y(y1)), (map-x(x2), map-y(y1)), stroke: (paint: ink, thickness: 1.1pt, dash: "dashed"))
        line((map-x(x2), map-y(y1)), (map-x(x2), map-y(y2)), stroke: (paint: accent-red, thickness: 1.6pt))
        content((map-x(14.0), map-y(y1) - 0.34), text(size: 8.5pt, weight: "bold", fill: ink)[+4 ans])
        content((map-x(x2) + 0.78, map-y((y1 + y2) / 2) - 0.02), text(size: 8.5pt, weight: "bold", fill: accent-red)[+53.8 k\$])

        content((map-x(9.5), map-y(228.0)), text(size: 9pt, weight: "bold", fill: accent-red)[ŷ = -100.4 + 13.4 × education (k\$)])
        content((3.7, -0.82), text(size: 9.5pt, weight: "bold", fill: ink)[Années d'études (education, 0 à 20 ans)])
        content((1.15, 5.65), text(size: 9.5pt, weight: "bold", fill: ink)[Revenu annuel (k\$ / an)])
      })
    ]
  ][
    #block(
      width: 100%,
      fill: dark-bg,
      radius: 3pt,
      inset: (x: 12pt, y: 10pt),
      [
        #text(size: 9pt, weight: "bold", fill: rgb("#adb5bd"))[CODE PYTHON (OLS : MOINDRES CARRÉS)]
        #v(4pt)
        #text(size: 9.5pt, fill: white)[
          #raw("smf.ols(\"annual_income ~ education\", data=df).fit()")
        ]
      ],
    )
    #v(14pt)
    #text(size: 14.5pt, weight: "bold", fill: ink)[Seulement 2 paramètres lisibles]
    #v(6pt)
    #set text(size: 11.8pt)
    - *Constante (`β0`) = `-100 399 $`* : niveau théorique à `education = 0` (extrapolation hors des données).
    - *Pente `education` (`β1`) = #text(fill: accent-red)[`+13 445 $ / an`]* par année d'études : soit *`+53 780 $`* (`+53.8 k$`) pour `+4` ans d'études (`p < 0.001`).

    #v(14pt)
    #line(length: 100%, stroke: 0.6pt + border-col)
    #v(10pt)

    #grid(
      columns: (1fr, 1fr),
      gutter: 16pt,
      [
        #text(size: 22pt, weight: "bold", fill: ink)[0.18] \
        #text(size: 10.5pt, weight: "bold", fill: ink)[Part expliquée (`R²`)] \
        #text(size: 9.5pt, fill: muted)[Variance captée par `education`]
      ],
      [
        #text(size: 20pt, weight: "bold", fill: accent-red)[70 289 \$ / an] \
        #text(size: 10.5pt, weight: "bold", fill: ink)[Erreur moyenne (`RMSE`)] \
        #text(size: 9.5pt, fill: muted)[Moyenne : 97 347 \$ / an]
      ],
    )
  ]
]

// ============================================================================
// Slide 9 : Plusieurs leviers : le modèle de revenu (7 paramètres)
// ============================================================================

#wslide(title: "Plusieurs leviers : le modèle de revenu (7 paramètres)")[
  #grid(
    columns: (1fr, auto),
    gutter: 14pt,
    align: horizon,
    block(fill: dark-bg, radius: 3pt, inset: (x: 11pt, y: 6.5pt), width: 100%)[
      #text(size: 8.4pt, fill: white)[
        #raw("smf.ols(\"annual_income ~ education + age + employed + married + female + minority\", data=df).fit()")
      ]
    ],
    [
      #text(size: 10.5pt, weight: "bold", fill: ink)[7 paramètres]
      #h(6pt) #text(fill: border-col)[|] #h(6pt)
      #text(size: 10.5pt, weight: "bold", fill: accent-red)[R² = 0.31]
      #h(6pt) #text(fill: border-col)[|] #h(6pt)
      #text(size: 10.5pt, weight: "bold", fill: ink)[RMSE = 64 267 \$]
    ],
  )

  #v(10pt)

  #set text(size: 10.6pt)
  #table(
    columns: (1.35fr, 0.92fr, 0.90fr, 1.83fr),
    inset: (x: 8pt, y: 5.5pt),
    stroke: (_, row) => (
      top: if row == 0 { 1.2pt + ink } else { 0.4pt + border-col },
      bottom: if row == 0 { 1.2pt + ink } else if row == 7 { 1pt + accent-red } else { 0.4pt + border-col },
      left: none,
      right: none,
    ),
    fill: (_, row) => if row in (6, 7) { rgb("#fff5f5") } else { white },
    align: (left, center, right, left),
    text(weight: "bold", fill: ink)[Variable (`β0` + 6 leviers)],
    text(weight: "bold", fill: ink)[Échelle (moyenne)],
    text(weight: "bold", fill: ink)[Coefficient],
    text(weight: "bold", fill: ink)[Interprétation et significativité],

    [*Constante (`β0`)*], [Point de départ], [*`-87 268 $`*], [Niveau de référence théorique avant ajout des leviers],
    [*`education`*], [`6` à `20` ans (`14.7`)], [#text(weight: "bold", fill: ink)[`+10 998 $ / an`]], [Rendement de chaque année d'études (`p < 0.001`)],
    [*`age`*], [`18` à `80` ans (`52.7`)], [#text(weight: "bold", fill: ink)[`-227 $ / an`]], [Pente linéaire moyenne sur l'âge adulte (`p < 0.001`)],
    [*`employed`*], [`0 / 1` (`68.8 %`)], [#text(weight: "bold", fill: ink)[`+24 855 $ / an`]], [Prime liée à l'exercice d'un emploi (`p < 0.001`)],
    [*`married`*], [`0 / 1` (`51.6 %`)], [#text(weight: "bold", fill: ink)[`+48 093 $ / an`]], [Effet foyer à deux revenus et statut marital (`p < 0.001`)],
    [#text(weight: "bold", fill: accent-red)[`female`] #text(size: 8.6pt, fill: accent-red)[(Sexe)]], [`0 / 1` (`53.2 %`)], [#text(weight: "bold", fill: accent-red)[`-8 007 $ / an`]], [#text(fill: accent-red)[Écart significatif à profil égal (`p < 0.001 ***`) : signal d'alerte]],
    [#text(weight: "bold", fill: accent-red)[`minority`] #text(size: 8.6pt, fill: accent-red)[(Origine)]], [`0 / 1` (`27.5 %`)], [#text(weight: "bold", fill: accent-red)[`-10 328 $ / an`]], [#text(fill: accent-red)[Écart significatif à profil égal (`p < 0.001 ***`) : signal d'alerte]],
  )

  #v(8pt)

  #block(
    width: 100%,
    stroke: (left: 2.5pt + accent-red),
    inset: (left: 12pt, y: 2pt),
    [
      #text(size: 10.6pt, fill: ink)[
        *Lecture critique :* à diplôme, âge, emploi et situation familiale identiques, les deux critères sociaux restent hautement significatifs (`female` : #text(weight: "bold", fill: accent-red)[-8 007 \$], `minority` : #text(weight: "bold", fill: accent-red)[-10 328 \$], `p < 0.001`). Dans un scoring équitable (crédit, RH), ces poids doivent être audités.
      ]
    ],
  )
]

// ============================================================================
// Slide 10 : Démo en direct : Workshop IA Explicable (XAI)
// ============================================================================

#wslide(title: "Démo en direct : Workshop IA Explicable (XAI)")[
  #top-cols(columns: (1fr, 1fr, 1fr), gutter: 1.8em)[
    #line(length: 100%, stroke: 1.5pt + muted)
    #v(8pt)
    #grid(
      columns: (auto, 1fr),
      gutter: 10pt,
      align: horizon,
      text(size: 22pt, weight: "bold", fill: muted)[02],
      text(size: 10pt, weight: "bold", fill: muted, tracking: 0.8pt)[ONGLET 2],
    )
    #v(6pt)
    #text(size: 15pt, weight: "bold", fill: ink)[Une droite]
    #v(8pt)
    #set text(size: 11.4pt)
    - Partir d'une droite en `(0, 0)` sur *100 points réels* (`seed = 5`, `1` profil `< 10` ans, axe `0` à `20`), puis ajuster l'OLS (`-99.9 k$ + 13.6 k$ × education`, `RMSE = 70 283 $`).
    - *Cliquer* pour ajouter un point et afficher les résidus / RMSE.
  ][
    #line(length: 100%, stroke: 1.5pt + ink)
    #v(8pt)
    #grid(
      columns: (auto, 1fr),
      gutter: 10pt,
      align: horizon,
      text(size: 22pt, weight: "bold", fill: ink)[03],
      text(size: 10pt, weight: "bold", fill: ink, tracking: 0.8pt)[ONGLET 3],
    )
    #v(6pt)
    #text(size: 15pt, weight: "bold", fill: ink)[Des paramètres]
    #v(8pt)
    #set text(size: 11.4pt)
    - Régler les *6 leviers* (dont `female` et `minority`, `p < 0.001 ***`) pour construire un profil de foyer.
    - Lire chaque contribution en *`$ / an`* autour de la moyenne (`97 347 $ / an`).
  ][
    #line(length: 100%, stroke: 1.5pt + accent-red)
    #v(8pt)
    #grid(
      columns: (auto, 1fr),
      gutter: 10pt,
      align: horizon,
      text(size: 22pt, weight: "bold", fill: accent-red)[04],
      text(size: 10pt, weight: "bold", fill: accent-red, tracking: 0.8pt)[ONGLET 4],
    )
    #v(6pt)
    #text(size: 15pt, weight: "bold", fill: ink)[Deep Learning]
    #v(8pt)
    #set text(size: 11.4pt)
    - Passer du modèle transparent (`7` paramètres) à la *boîte noire* via le *réseau de neurones interactif* (`329` paramètres, `R² = 0.34`).
    - Lancer des *sondes locales* (et voir l'effet proxy type COMPAS).
  ]

  #v(18pt)

  #callout-strip(
    "Navigation (5 onglets)",
    [
      *Onglet 1 (Introduction) :* citation de G. Box, modèle, algorithme, XAI. *Onglets 2, 3 et 4 :* mêmes données, seule change l'architecture. *Onglet 5 (Hack-time) :* accès direct au notebook *Google Colab*.
    ],
    accent: accent-red,
  )
]

// ============================================================================
// Slide 11 : Entrer dans le Deep Learning
// ============================================================================

#wslide(title: "Entrer dans le Deep Learning")[
  #cols(columns: (1.28fr, 0.92fr), gutter: 2em)[
    #align(center)[
      #diagram(
        spacing: (7.2mm, 6.8mm),
        node-stroke: 1pt,

        node((1, -0.65), text(size: 8pt, weight: "bold", fill: ink)[ENTRÉES (6)], stroke: none, fill: none),
        node((2, -0.65), text(size: 8pt, weight: "bold", fill: muted)[COUCHE 1 (16)], stroke: none, fill: none),
        node((3, -0.65), text(size: 8pt, weight: "bold", fill: muted)[COUCHE 2 (12)], stroke: none, fill: none),
        node((4, -0.65), text(size: 8pt, weight: "bold", fill: accent-red)[SORTIE (1)], stroke: none, fill: none),

        node((0, 0.0), align(right)[#text(size: 8pt, weight: "bold", fill: ink)[education]], stroke: none, fill: none),
        node((0, 0.78), align(right)[#text(size: 8pt, weight: "bold", fill: ink)[age]], stroke: none, fill: none),
        node((0, 1.56), align(right)[#text(size: 8pt, weight: "bold", fill: ink)[employed]], stroke: none, fill: none),
        node((0, 2.34), align(right)[#text(size: 8pt, weight: "bold", fill: ink)[married]], stroke: none, fill: none),
        node((0, 3.12), align(right)[#text(size: 8pt, weight: "bold", fill: accent-red)[female]], stroke: none, fill: none),
        node((0, 3.90), align(right)[#text(size: 8pt, weight: "bold", fill: accent-red)[minority]], stroke: none, fill: none),

        for i in range(6) {
          let col = if i >= 4 { accent-red } else { ink }
          let bg = if i >= 4 { rgb("#fff5f5") } else { surface }
          node((1, i * 0.78), text(size: 7.8pt, weight: "bold", fill: col)[$x_#(i + 1)$],
            shape: "circle", radius: 3.3mm, fill: bg, stroke: 1.3pt + col)
        },

        for j in (0.4, 1.35, 2.55, 3.5) {
          node((2, j), [], shape: "circle", radius: 3.1mm, fill: surface, stroke: 1.1pt + muted)
        },
        node((2, 1.95), text(size: 10pt, weight: "bold", fill: muted)[⋮], stroke: none, fill: none),

        for k in (0.75, 1.95, 3.15) {
          node((3, k), [], shape: "circle", radius: 3.1mm, fill: surface, stroke: 1.1pt + muted)
        },
        node((3, 1.35), text(size: 10pt, weight: "bold", fill: muted)[⋮], stroke: none, fill: none),

        node((4, 1.95), text(size: 9pt, weight: "bold", fill: accent-red)[$hat(y)$],
          shape: "circle", radius: 4.2mm, fill: rgb("#fff5f5"), stroke: 1.8pt + accent-red),
        node((5, 1.95), align(left)[#text(size: 8pt, weight: "bold", fill: accent-red)[Revenu \ prédit]], stroke: none, fill: none),

        for i in range(6) {
          for j in (0.4, 1.35, 2.55, 3.5) {
            let lcol = if i >= 4 { accent-red.lighten(60%) } else { border-col }
            edge((1, i * 0.78), (2, j), stroke: 0.45pt + lcol)
          }
        },

        for j in (0.4, 1.35, 2.55, 3.5) {
          for k in (0.75, 1.95, 3.15) {
            edge((2, j), (3, k), stroke: 0.5pt + rgb("#94a3b8"))
          }
        },

        for k in (0.75, 1.95, 3.15) {
          edge((3, k), (4, 1.95), "->", stroke: 0.85pt + accent-red.lighten(30%))
        },
      )
    ]
    #v(8pt)
    #line(length: 100%, stroke: 0.6pt + border-col)
    #v(6pt)
    #grid(
      columns: (1fr, auto),
      align: horizon,
      text(size: 9.2pt, style: "italic", fill: muted)[Réseau multicouche (MLP : 6 → 16 → 12 → 1)],
      text(size: 9.6pt, weight: "bold", fill: accent-red)[329 paramètres | R² = 0.34 | RMSE = 62 837 \$],
    )
  ][
    #text(size: 14pt, weight: "bold", fill: ink)[1. Courbe non linéaire de l'âge]
    #v(5pt)
    #set text(size: 11.4pt)
    Sur nos données réelles, l'OLS résume mal la hausse de carrière puis la baisse à la retraite avec une pente plate (`-227 $ / an`). Le MLP capte cette bosse courbe et fait monter `R²` de `0.31` à `0.34`.

    #v(12pt)
    #line(length: 100%, stroke: 0.6pt + border-col)
    #v(10pt)

    #text(size: 14pt, weight: "bold", fill: ink)[2. Poids partagés & variables proxy]
    #v(5pt)
    Chaque entrée irrigue les *16* puis *12 neurones* : aucun poids isolé ne donne un effet clair. Même sans `female` ou `minority`, `education`, `married` et `employed` en portent la trace indirecte.

    #v(12pt)

    #block(
      width: 100%,
      fill: surface,
      stroke: (left: 3pt + accent-red),
      inset: (x: 12pt, y: 8pt),
      [
        #text(size: 11.2pt, weight: "bold", fill: accent-red)[Résultat :]
        #text(size: 11.2pt, fill: ink)[ on gagne en flexibilité (`R²` de `0.31` à `0.34`, `RMSE` à `62 837 $ / an`), mais on perd la lecture directe.]
      ],
    )
  ]
]

// ============================================================================
// Slide 12 : L'explosion des paramètres
// ============================================================================

#wslide(title: "L'explosion des paramètres : de 2 à 1 000 milliards")[
  #top-cols(columns: (1fr, 1fr, 1fr, 1fr), gutter: 1.5em)[
    #line(length: 100%, stroke: 1.5pt + border-col)
    #v(8pt)
    #text(size: 9.5pt, weight: "bold", fill: muted, tracking: 0.8pt)[PALIER 01]
    #v(4pt)
    #box(height: 28pt, align(bottom, text(size: 24pt, weight: "bold", fill: muted)[2])) \
    #text(size: 11pt, weight: "bold", fill: ink)[paramètres]
    #v(8pt)
    #line(length: 100%, stroke: 0.5pt + border-col)
    #v(8pt)
    #set text(size: 11pt)
    *OLS simple* (`Y ~ X`)
    #v(4pt)
    - `R² = 0.18`
    - `RMSE = 70.3 k$`
    - *Lisibilité :* totale (1 pente).
  ][
    #line(length: 100%, stroke: 1.5pt + muted)
    #v(8pt)
    #text(size: 9.5pt, weight: "bold", fill: muted, tracking: 0.8pt)[PALIER 02]
    #v(4pt)
    #box(height: 28pt, align(bottom, text(size: 24pt, weight: "bold", fill: ink)[7])) \
    #text(size: 11pt, weight: "bold", fill: ink)[paramètres]
    #v(8pt)
    #line(length: 100%, stroke: 0.5pt + border-col)
    #v(8pt)
    #set text(size: 11pt)
    *OLS complet* (`6` leviers)
    #v(4pt)
    - `R² = 0.31`
    - `RMSE = 64.3 k$`
    - *Lisibilité :* totale (additif).
  ][
    #line(length: 100%, stroke: 1.5pt + ink)
    #v(8pt)
    #text(size: 9.5pt, weight: "bold", fill: ink, tracking: 0.8pt)[PALIER 03]
    #v(4pt)
    #box(height: 28pt, align(bottom, text(size: 24pt, weight: "bold", fill: ink)[329])) \
    #text(size: 11pt, weight: "bold", fill: ink)[paramètres]
    #v(8pt)
    #line(length: 100%, stroke: 0.5pt + border-col)
    #v(8pt)
    #set text(size: 11pt)
    *Petit MLP* (`2` couches)
    #v(4pt)
    - `R² = 0.34`
    - `RMSE = 62.8 k$`
    - *Lisibilité :* opaque (poids mêlés).
  ][
    #line(length: 100%, stroke: 1.5pt + accent-red)
    #v(8pt)
    #text(size: 9.5pt, weight: "bold", fill: accent-red, tracking: 0.8pt)[PALIER 04]
    #v(4pt)
    #box(height: 28pt, align(bottom, text(size: 15.5pt, weight: "bold", fill: accent-red)[70 Md à 1 000+ Md])) \
    #text(size: 11pt, weight: "bold", fill: ink)[paramètres]
    #v(8pt)
    #line(length: 100%, stroke: 0.5pt + border-col)
    #v(8pt)
    #set text(size: 11pt)
    *Grands modèles (LLM)*
    #v(4pt)
    - Même empilement appliqué au texte
    - *Lisibilité :* boîte noire totale sur les poids.
  ]

  #v(22pt)

  #grid(
    columns: (auto, 1fr, auto),
    gutter: 14pt,
    align: horizon,
    text(size: 11pt, weight: "bold", fill: muted)[Lisibilité maximale],
    box(
      width: 100%,
      height: 7pt,
      radius: 3.5pt,
      fill: gradient.linear(rgb("#e2e8f0"), muted, ink, accent-red),
    ),
    text(size: 11pt, weight: "bold", fill: accent-red)[Capacité maximale / Opacité],
  )
  #v(8pt)
  #align(center, text(size: 11.8pt, fill: ink)[
    Plus le nombre de paramètres croît, plus la prédiction devient performante, mais plus il devient impossible d'expliquer le résultat par simple lecture des poids.
  ])
]

// ============================================================================
// Slide 13 : Qu'est-ce que l'IA Explicable (XAI) ?
// ============================================================================

#wslide(title: "Qu'est-ce que l'IA Explicable (XAI) ?")[
  #top-cols(columns: (1fr, 1fr), gutter: 2.2em)[
    #num-head("01", "Explicabilité intrinsèque", accent: muted)
    #v(4pt)
    #text(size: 10.5pt, weight: "bold", fill: muted)[Approche « boîte de verre »]
    #v(10pt)
    - Le modèle est *lisible par construction* : régression linéaire, régression logistique, arbre de décision peu profond.
    - Les paramètres du modèle sont *directement l'explication*.
    - Pas besoin de méthode secondaire : on lit la formule et les signes.
  ][
    #num-head("02", "Explicabilité post-hoc", accent: accent-red)
    #v(4pt)
    #text(size: 10.5pt, weight: "bold", fill: accent-red)[Sondes sur une « boîte noire »]
    #v(10pt)
    - *Perturbations locales (SHAP, LIME) :* on fait bouger chaque variable autour d'un individu pour estimer son poids local.
    - *Contrefactuels :* #emph[« Que faudrait-il modifier dans ce foyer pour que la prédiction change ? »]
    - *Mise en récit par LLM :* traduire les scores en phrase claire.
  ]

  #v(18pt)

  #callout-strip(
    "Vigilance & AI Act",
    [
      Une explication post-hoc (SHAP, LIME) est une *approximation locale* qui ne prouve *jamais une causalité*. Sur de vraies données comme dans les systèmes à haut risque (COMPAS, crédit, recrutement, *AI Act européen*), l'XAI sert à auditer les biais (`female`, `minority`) et leurs *variables proxy*.
    ],
    accent: accent-red,
  )
]

// ============================================================================
// Slide 14 : Section 03
// ============================================================================

#title-slide[
  03 · Atelier pratique : Construire un profil
]

// ============================================================================
// Slide 15 : Votre mission (15-20 min)
// ============================================================================

#wslide(title: "Votre mission (15 à 20 min)")[
  #top-cols(columns: (1fr, 1fr, 1fr), gutter: 1.8em)[
    #line(length: 100%, stroke: 1.5pt + muted)
    #v(8pt)
    #text(size: 22pt, weight: "bold", fill: muted)[01]
    #v(6pt)
    #text(size: 14.5pt, weight: "bold", fill: ink)[Tester le clic & les résidus]
    #v(8pt)
    #set text(size: 11.2pt)
    - Sur l'#strong[Onglet 2] (`Une droite`, `100` points réels), cochez #emph[Afficher les erreurs (résidus)], puis ajoutez un point au clic.
    - Testez `female` et `minority` sur les *Onglets 3 et 4* (`7` vs `329` paramètres).
  ][
    #line(length: 100%, stroke: 1.5pt + ink)
    #v(8pt)
    #text(size: 22pt, weight: "bold", fill: ink)[02]
    #v(6pt)
    #text(size: 14.5pt, weight: "bold", fill: ink)[Exécuter `smf.ols` sur Colab]
    #v(8pt)
    #set text(size: 11.2pt)
    - Depuis l'#strong[Onglet 5] (`Hack-time`), ouvrez le #link("https://colab.research.google.com/github/mickaeltemporao/workshop-xai/blob/main/notebooks/atelier-xai-citoyen.ipynb")[#text(weight: "bold", fill: accent-red)[notebook Google Colab]] (dépôt #link("https://github.com/mickaeltemporao/workshop-xai")[GitHub]).
    - Chargez les données d'enquête et retrouvez `R² = 0.31`, `female` (`-8 007 $`) et `minority` (`-10 328 $`).
  ][
    #line(length: 100%, stroke: 1.5pt + accent-red)
    #v(8pt)
    #text(size: 22pt, weight: "bold", fill: accent-red)[03]
    #v(6pt)
    #text(size: 14.5pt, weight: "bold", fill: ink)[Comparer `7` vs `329` paramètres]
    #v(8pt)
    #set text(size: 11.2pt)
    - Basculez `female` ou `minority` puis variez une variable $X_i$ à la fois.
    - Confrontez boîte de verre (`7` params) et boîte noire (`329` params) sur des profils contrastés.
  ]

  #v(14pt)

  #callout-strip(
    "Question fil rouge",
    [
      Comment évolue l'effet de l'`age` à `30` ans vs `70` ans dans la boîte noire (`329` paramètres) face au `-227 $ / an` fixe de la régression ?
    ],
    accent: accent-red,
  )

  #v(10pt)
  #align(left, text(size: 9pt, fill: muted)[
    Application : #link("https://mickaeltemporao.github.io/workshop-xai/")[mickaeltemporao.github.io/workshop-xai] | Licence CC BY-NC-SA 4.0 | Note IA : supports et code conçus avec l'assistance d'outils d'IA générative, relus et validés par l'intervenant.
  ])
]

// ============================================================================
// Slide 16 : Cloture
// ============================================================================

#focus-slide[
  #set text(fill: white)
  #set underline(stroke: 1.2pt + white, offset: 3pt)
  Merci !
  #v(0.6cm)
  #text(size: 18pt, weight: "regular", fill: white)[
    #link("https://mickaeltemporao.github.io/workshop-xai/")[#text(fill: white)[mickaeltemporao.github.io/workshop-xai]] \
    #link("https://github.com/mickaeltemporao/workshop-xai")[#text(fill: white)[github.com/mickaeltemporao/workshop-xai]]
  ]
]
