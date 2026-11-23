// ============================================================================
// Sciences Po Bordeaux - Atelier IA Explicable (XAI) Slide Template
// Graphic Charter: Bitter (Headings) & Myriad Pro (Body)
// Brand Colors: IEP Red (#dd1019), Anthracite (#2f3235), and Accents
// ============================================================================

// ----------------------------------------------------------------------------
// Color Palette (Sciences Po Bordeaux Graphic Charter)
// ----------------------------------------------------------------------------
#let iep-red = rgb("#dd1019")
#let iep-anthracite = rgb("#2f3235")
#let iep-dark-bg = rgb("#1e2124")
#let iep-light-bg = rgb("#ffffff")
#let iep-surface = rgb("#f8f9fa")
#let iep-surface-subtle = rgb("#f1f3f5")
#let iep-border = rgb("#e9ecef")
#let iep-border-dark = rgb("#3d4246")

// Charter Secondary Accents
#let iep-bleu-vert = rgb("#024d5f")
#let iep-turquoise = rgb("#00999a")
#let iep-indigo = rgb("#0072bc")
#let iep-bleu-fonce = rgb("#0f315e")
#let iep-framboise = rgb("#ab1e52")
#let iep-violet = rgb("#641f61")
#let iep-orange = rgb("#f7941e")
#let iep-vert = rgb("#00854a")
#let iep-vert-anis = rgb("#cadb44")
#let iep-jaune = rgb("#fbd238")
#let iep-gray = rgb("#6c757d")
#let iep-muted = rgb("#868e96")

// Fonts
#let font-heading = "Bitter"
#let font-body = "Myriad Pro"

// ----------------------------------------------------------------------------
#let iep-topic-state = state("iep-topic", "IA Explicable")

#let iep-presentation(
  course: "Atelier XAI",
  year: "2026",
  author: "Mickael Temporão",
  affiliation: "Sciences Po Bordeaux | Centre Émile Durkheim",
  topic: "IA Explicable",
  body
) = {
  set document(title: course, author: author)
  set page(
    paper: "presentation-16-9",
    margin: (x: 1.8cm, top: 2.2cm, bottom: 1.5cm),
    fill: iep-light-bg,
  )
  set text(
    font: font-body,
    size: 17.5pt,
    fill: iep-anthracite,
    weight: "regular",
    lang: "fr"
  )
  set par(leading: 0.6em, justify: false)

  iep-topic-state.update(topic)
  body
}

// ----------------------------------------------------------------------------
// Slide Layouts
// ----------------------------------------------------------------------------

#let iep-title-slide-state = state("iep-title-slide", (
  lecture-num: "Atelier",
  course-name: "IA Explicable (XAI)",
  title: "De la régression aux grands modèles de langage",
  subtitle: none,
  author: "Mickael Temporão",
  affiliation: "Sciences Po Bordeaux | Centre Émile Durkheim",
  year: "2026",
  logo-path: "/branding/logo-sciences-po-bordeaux.svg",
))

// Internal renderer for title slide layout
#let render-title-slide(
  lecture-num: "Atelier",
  course-name: "IA Explicable (XAI)",
  title: "De la régression aux grands modèles de langage",
  subtitle: none,
  author: "Mickael Temporão",
  affiliation: "Sciences Po Bordeaux | Centre Émile Durkheim",
  year: "2026",
  logo-path: "/branding/logo-sciences-po-bordeaux.svg",
) = {
  set page(
    margin: 0pt,
    header: none,
    footer: none,
    fill: iep-dark-bg,
  )

  place(top + left, rect(
    width: 100%,
    height: 8pt,
    fill: iep-red
  ))

  block(
    width: 100%,
    height: 100%,
    inset: (x: 2.2cm, top: 2cm, bottom: 1.8cm),
    {
      if logo-path != none {
        align(right,
          box(
            fill: white,
            radius: 6pt,
            inset: 8pt,
            image(logo-path, width: 4.5cm)
          )
        )
      }

      v(1fr)

      // Lecture Number & Course Name / Title
      block(
        stroke: (left: 4.5pt + iep-red),
        inset: (left: 18pt, y: 4pt),
        [
          #text(font: font-heading, size: 20pt, weight: "regular", fill: rgb("#e9ecef"))[
            #text(fill: iep-red, weight: "bold")[#lecture-num] #h(8pt) | #h(8pt) #course-name
          ]
          #v(10pt)
          #text(font: font-heading, size: 32pt, weight: "bold", fill: white)[
            #title
          ]
          #if subtitle != none [
            #v(8pt)
            #text(font: font-heading, size: 20pt, weight: "regular", fill: rgb("#ced4da"))[
              #subtitle
            ]
          ]
        ]
      )

      v(1.2fr)

      // Author & Affiliation Footer
      line(length: 100%, stroke: 0.5pt + iep-border-dark)
      v(10pt)
      grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        [
          #text(font: font-body, size: 15pt, weight: "bold", fill: white)[#author] \
          #text(font: font-body, size: 12.5pt, fill: rgb("#9ca3af"))[#affiliation]
        ],
        [
          #text(font: font-body, size: 12.5pt, fill: rgb("#adb5bd"))[#year]
        ]
      )
    }
  )
}

// 1b. Closing Slide (Exact duplicate of the opening title slide)
#let closing-slide(
  lecture-num: auto,
  course-name: auto,
  title: auto,
  subtitle: auto,
  author: auto,
  affiliation: auto,
  year: auto,
  logo-path: auto,
) = {
  context {
    let saved = iep-title-slide-state.get()
    let data = if saved != none { saved } else { (:) }

    let l-num = if lecture-num != auto { lecture-num } else { data.at("lecture-num", default: "Atelier") }
    let c-name = if course-name != auto { course-name } else { data.at("course-name", default: "IA Explicable (XAI)") }
    let t = if title != auto { title } else { data.at("title", default: "De la régression aux grands modèles de langage") }
    let sub = if subtitle != auto { subtitle } else { data.at("subtitle", default: none) }
    let a = if author != auto { author } else { data.at("author", default: "Mickael Temporão") }
    let aff = if affiliation != auto { affiliation } else { data.at("affiliation", default: "Sciences Po Bordeaux | Centre Émile Durkheim") }
    let yr = if year != auto { year } else { data.at("year", default: "2026") }
    let logo = if logo-path != auto { logo-path } else { data.at("logo-path", default: "/branding/logo-sciences-po-bordeaux.svg") }

    render-title-slide(
      lecture-num: l-num,
      course-name: c-name,
      title: t,
      subtitle: sub,
      author: a,
      affiliation: aff,
      year: yr,
      logo-path: logo,
    )
  }
}

// 1. Title Slide (Impactful Dark / IEP Red Header)
#let title-slide(
  lecture-num: auto,
  course-name: auto,
  title: auto,
  subtitle: auto,
  author: auto,
  affiliation: auto,
  year: auto,
  logo-path: auto,
) = {
  if lecture-num == auto and title == auto {
    closing-slide(
      lecture-num: lecture-num,
      course-name: course-name,
      title: title,
      subtitle: subtitle,
      author: author,
      affiliation: affiliation,
      year: year,
      logo-path: logo-path,
    )
  } else {
    let l-num = if lecture-num != auto { lecture-num } else { "Atelier" }
    let c-name = if course-name != auto { course-name } else { "IA Explicable (XAI)" }
    let t = if title != auto { title } else { "De la régression aux grands modèles de langage" }
    let sub = if subtitle != auto { subtitle } else { none }
    let a = if author != auto { author } else { "Mickael Temporão" }
    let aff = if affiliation != auto { affiliation } else { "Sciences Po Bordeaux | Centre Émile Durkheim" }
    let yr = if year != auto { year } else { "2026" }
    let logo = if logo-path != auto { logo-path } else { "/branding/logo-sciences-po-bordeaux.svg" }

    iep-title-slide-state.update((
      lecture-num: l-num,
      course-name: c-name,
      title: t,
      subtitle: sub,
      author: a,
      affiliation: aff,
      year: yr,
      logo-path: logo,
    ))

    render-title-slide(
      lecture-num: l-num,
      course-name: c-name,
      title: t,
      subtitle: sub,
      author: a,
      affiliation: aff,
      year: yr,
      logo-path: logo,
    )
  }
}

// 2. Section Transition Slide (Bold Monochromatic with Red Accent)
#let section-slide(
  num: none,
  title: "Titre de section",
  subtitle: none,
  tag: none,
  bg-color: iep-dark-bg,
  accent-color: iep-red
) = {
  set page(
    margin: 0pt,
    header: none,
    footer: none,
    fill: bg-color,
  )

  place(top + left, rect(
    width: 100%,
    height: 6pt,
    fill: accent-color
  ))

  place(center + horizon,
    block(
      width: 82%,
      [
        #if num != none [
          #grid(
            columns: (auto, 1fr),
            gutter: 24pt,
            align: horizon,
            [
              #text(font: font-heading, size: 56pt, weight: "bold", fill: accent-color)[#num]
            ],
            [
              #if tag != none [
                #box(
                  fill: rgb(255, 255, 255, 12%),
                  radius: 3pt,
                  inset: (x: 8pt, y: 3pt),
                  text(font: font-body, size: 11pt, weight: "bold", fill: rgb("#dee2e6"), tracking: 1.5pt)[
                    #upper(tag)
                  ]
                )
                #v(6pt)
              ]
              #text(font: font-heading, size: 36pt, weight: "bold", fill: white)[#title]
              #if subtitle != none [
                #v(6pt)
                #text(font: font-body, size: 16pt, fill: rgb("#adb5bd"))[#subtitle]
              ]
            ]
          )
        ] else [
          #align(center, [
            #if tag != none [
              #box(
                fill: rgb(255, 255, 255, 12%),
                radius: 3pt,
                inset: (x: 8pt, y: 3pt),
                text(font: font-body, size: 11pt, weight: "bold", fill: rgb("#dee2e6"), tracking: 1.5pt)[
                  #upper(tag)
                ]
              )
              #v(10pt)
            ]
            #text(font: font-heading, size: 36pt, weight: "bold", fill: white)[#title]
            #if subtitle != none [
              #v(8pt)
              #text(font: font-body, size: 18pt, fill: rgb("#adb5bd"))[#subtitle]
            ]
          ])
        ]
      ]
    )
  )
}

// 3. Standard Content Slide
#let slide(
  title: none,
  subtitle: none,
  category: none,
  topic: auto,
  v-align: horizon,
  body
) = {
  set page(
    header: {
      if title != none {
        block(
          width: 100%,
          inset: (bottom: 10pt),
          stroke: (bottom: 1pt + iep-border),
          [
            #grid(
              columns: (1fr, auto),
              align: (left + horizon, right + horizon),
              [
                #if category != none [
                  #text(font: font-body, size: 10pt, weight: "bold", fill: iep-red, tracking: 1pt)[
                    #upper(category)
                  ]
                  #v(2pt)
                ]
                #text(font: font-heading, size: 22pt, weight: "bold", fill: iep-anthracite)[
                  #title
                ]
                #if subtitle != none [
                  #h(10pt)
                  #text(font: font-body, size: 13.5pt, weight: "regular", fill: iep-gray)[
                    #subtitle
                  ]
                ]
              ],
              [
                #image("/branding/logo-sciences-po-bordeaux.svg", width: 2.6cm)
              ]
            )
          ]
        )
      }
    },
    footer: context {
      let page-num = counter(page).display()
      let current-topic = if topic != auto { topic } else { iep-topic-state.get() }
      block(
        width: 100%,
        inset: (top: 8pt),
        stroke: (top: 0.5pt + iep-border),
        [
          #grid(
            columns: (1fr, auto, 1fr),
            align: (left, center, right),
            [
              #text(font: font-body, size: 9.5pt, fill: iep-muted)[
                Atelier IA Explicable • Sciences Po Bordeaux
              ]
            ],
            [
              #text(font: font-body, size: 10pt, weight: "semibold", fill: iep-anthracite)[
                #current-topic
              ]
            ],
            [
              #text(font: font-heading, size: 10pt, weight: "bold", fill: iep-red)[
                #page-num
              ]
            ]
          )
        ]
      )
    }
  )

  grid(
    columns: 1fr,
    rows: 100%,
    align: v-align,
    body
  )
}

// 4. Focus / Big Quote / Big Question Slide
#let focus-slide(
  title: none,
  quote: none,
  author: none,
  source-info: none,
  bg-color: iep-dark-bg,
  accent-color: iep-red,
  body: none
) = {
  set page(
    margin: 0pt,
    header: none,
    footer: none,
    fill: bg-color,
  )

  place(top + left, rect(width: 100%, height: 6pt, fill: accent-color))

  place(center + horizon,
    block(
      width: 82%,
      [
        #if title != none [
          #align(center, [
            #text(font: font-heading, size: 36pt, weight: "bold", fill: white)[#title]
            #if source-info != none [
              #v(12pt)
              #text(font: font-body, size: 16pt, fill: rgb("#adb5bd"))[#source-info]
            ]
          ])
        ]
        #if quote != none [
          #text(font: font-heading, size: 44pt, fill: accent-color)[“]
          #v(-26pt)
          #text(font: font-heading, size: 22pt, weight: "regular", fill: white, style: "italic")[
            #quote
          ]
          #if author != none [
            #v(12pt)
            #align(right, [
              #text(font: font-body, size: 15pt, weight: "bold", fill: accent-color)[- #author]
              #if source-info != none [
                #h(6pt)
                #text(font: font-body, size: 13pt, fill: rgb("#adb5bd"))[(#source-info)]
              ]
            ])
          ]
        ]
        #if body != none [
          #body
        ]
      ]
    )
  )
}

// ----------------------------------------------------------------------------
// Component Library & Layout Helpers (Sober & Minimalist Design)
// ----------------------------------------------------------------------------

// Content Card (Standalone Box)
#let card(
  title: none,
  body,
  color: iep-red,
  fill: rgb("#fafafa"),
  stroke: none,
  radius: 4pt,
  inset: (x: 14pt, y: 12pt),
  height: auto
) = {
  let actual-stroke = if stroke != none { stroke } else { (left: 2.5pt + color, rest: 0.5pt + rgb("#e2e8f0")) }
  box(
    width: 100%,
    height: height,
    fill: fill,
    radius: radius,
    stroke: actual-stroke,
    inset: inset,
    outset: 0pt,
    [
      #if title != none [
        #text(font: font-heading, size: 13pt, weight: "bold", fill: iep-anthracite)[#title]
        #v(5pt)
      ]
      #set text(font: font-body, size: 12pt, fill: rgb("#2d3748"))
      #body
    ]
  )
}

// Sleek Grid Card (Matches sibling height automatically in any grid row)
#let grid-card(
  title: none,
  body,
  color: iep-red,
  fill: rgb("#fafafa"),
  stroke: none,
  inset: (x: 14pt, y: 12pt),
  align: top + left
) = {
  let actual-stroke = if stroke != none { stroke } else { (left: 2.5pt + color, rest: 0.5pt + rgb("#e2e8f0")) }
  grid.cell(
    fill: fill,
    stroke: actual-stroke,
    inset: inset,
    align: align,
    [
      #if title != none [
        #text(font: font-heading, size: 13pt, weight: "bold", fill: iep-anthracite)[#title]
        #v(5pt)
      ]
      #set text(font: font-body, size: 11.5pt, fill: rgb("#2d3748"))
      #body
    ]
  )
}

// Stat Callout Box
#let stat-box(
  num,
  label,
  sublabel: none,
  color: iep-red,
  fill: rgb("#fafafa")
) = {
  box(
    width: 100%,
    fill: fill,
    radius: 4pt,
    stroke: (left: 3pt + color, rest: 0.5pt + rgb("#e2e8f0")),
    inset: (x: 16pt, y: 12pt),
    [
      #text(font: font-heading, size: 26pt, weight: "bold", fill: color)[#num] \
      #v(2pt)
      #text(font: font-body, size: 12.5pt, weight: "bold", fill: iep-anthracite)[#label]
      #if sublabel != none [
        \ #v(2pt)
        #text(font: font-body, size: 10.5pt, fill: rgb("#64748b"))[#sublabel]
      ]
    ]
  )
}

// Multi-Column Layouts
#let two-col(left, right, ratio: (1fr, 1fr), gutter: 16pt, align: top) = {
  grid(
    columns: ratio,
    gutter: gutter,
    align: align,
    left,
    right
  )
}

#let three-col(c1, c2, c3, gutter: 14pt) = {
  grid(
    columns: (1fr, 1fr, 1fr),
    gutter: gutter,
    c1,
    c2,
    c3
  )
}

// Source Citation Footer Note
#let source-note(text-content) = {
  place(
    bottom + right,
    dy: -2pt,
    text(font: font-body, size: 9.5pt, fill: iep-gray, style: "italic")[
      Source : #text-content
    ]
  )
}

// Pill / Tag badge
#let pill(text-content, color: iep-red, fill: none) = {
  let actual-fill = if fill == none { color.lighten(88%) } else { fill }
  box(
    fill: actual-fill,
    stroke: 0.5pt + color,
    radius: 4pt,
    inset: (x: 8pt, y: 3pt),
    text(font: font-body, size: 10.5pt, weight: "bold", fill: color)[#text-content]
  )
}
