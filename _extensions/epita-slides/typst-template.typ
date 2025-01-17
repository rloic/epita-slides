#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

 #let gimmick(size) = block(
  width: size,
  height: size * 1.081481481,
)[
  #let A = (0%, 54.5%)
  // #place(dx: 0%, dy: 54.5%, place(center + horizon)[+])
  #let B = (25%, 29%)
  // #place(dx: 25%, dy: 29%, place(center + horizon)[+])
  #let C = (97%, 0%)
  // #place(dx: 97%, dy: 0%, place(center + horizon)[+])
  #let D = (100%, 74.5%)
  // #place(dx: 100%, dy: 74.5%, place(center + horizon)[+])
  #let E = (75%, 100%)
  // #place(dx: 75%, dy: 100%, place(center + horizon)[+])
  #let F = (71.5%, 26.5%)
  // #place(dx: 71.5%, dy: 26.5%, place(center + horizon)[+])
  #let G = (49%, 60.5%)
  // #place(dx: 49%, dy: 60.5%, place(center + horizon)[+])

  #set path(stroke: (cap: "round"))
  #for pair in (
    (A, B), 
    (B, C),
    (C, D),
    (D, E),
    (E, A),
    (E, F),
    (E, G),
    (A, G),
    (A, F),
    (B, F),
    (G, F),
    (F, C),
    (E, C)
  ) {
    place(path( ..pair ))
  }
]

#let parse-date(date-str) = {
  let r = regex("[0-9]{4}-[0-9]{2}-[0-9]{2}")
  if date-str.starts-with(r) {
    let (year, month, day) = date-str.slice(0, 10).split("-").map(int)
    return datetime(year: year, month: month, day: day)
  } else {
    return date-str
  }
}

#let separator = box(height: 1em, baseline: .25em, text(size: .5em, align(horizon)[#h(.5em) • #h(.5em)]))

#let article(
  title: none,
  subtitle: none,
  authors: none,
  affiliations: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.5cm, top: 2cm, bottom: 1.5cm),
  paper: "16:9",
  lang: "fr",
  region: "FR",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  school: none,
  academic-year: none,
  acronym: none,
  doc,
) = {

  // Parsing
  let ratio = 0
  if paper == "16:9" {
    ratio = 16/9
  } else if paper == "4:3" {
    ratio = 4/3
  } else {
    panic("invalid ratio " + str(ratio) + ". valid ratios are 16:9 or 4:3")
  }

  let height = 12cm
  let width = ratio * height

  // Colors
  let dark-blue = rgb("#112d69")
  let pink = rgb("#b80e80")
  let block-color = dark-blue.lighten(90%)
  let body-color = dark-blue.lighten(80%)
  let header-color = dark-blue.lighten(60%)
  let fill-color = dark-blue.lighten(40%)

  // Styles
  let heading-style = (weight: "semibold", fill: dark-blue, font: "Chakra Petch")

  // Setup
  set document(
    title: title,
    author: authors.map(it => to-string(it.name)).join(", ", last: " and "),
  )
  set heading(numbering: none)
  set text(font: font, lang: lang)

  let header = context {  
    let page = here().page()
    let headings = query(selector(heading.where(level: 2)))
    let heading = headings.rev().find(x => x.location().page() <= page)

    if heading != none {
      set text(1.4em, ..heading-style, fill: pink)
      if not heading.location().page() == page {
        block(heading.body + numbering("(i)", page - heading.location().page() + 1))
      } else if heading.location().page() == page {
        block(heading.body)
      }
    }
  }

  let footer = {
    set text(.85em)
    context {
      let last = counter(page).final().first()
      let current = here().page()
      v(-0.3cm)
      grid(
        columns: (auto, 1fr, 1fr, auto),
        align: (left, right,left, right),
        inset: 4pt,
        authors.map(it => it.name).join(separator),
        smallcaps(title), [],
        [#context { counter(page).display("1 | 1", both: true)}]
      )
    }
  }

  let background = context {
    let current-page = counter(page).get().first() - 1
    let last-page = counter(page).final().first() - 1
    if current-page > 0 {
      set path(stroke: dark-blue.lighten(95%))
      place(bottom + left, dx: -1cm, dy: +1cm, gimmick(5cm))
      place(bottom + right, line(start: (0cm, 0cm), end: (100% - (current-page * 100% / last-page), 0cm), stroke: 6pt + pink.lighten(50%)))
      place(bottom + left, line(start: (0cm, 0cm), end: (current-page * 100% / last-page, 0cm), stroke: 6pt + pink))
    }
  }

  // PAGE----------------------------------------------
  set page(
    width: width,
    height: height,
    header-ascent: 40%,
    margin: margin,
    header: header,
    footer: footer,
    footer-descent: 75%,
    background: background
  )

  // SLIDES STYLING--------------------------------------------------
  // Section Slides
  set heading(numbering: sectionnumbering)
  show heading: (it) => {
    set text(..heading-style)
    set block(inset: (top: .5em))
    it
  }
  show heading.where(level: 1): (it) => {
    set page(header: none, footer: none, margin: 0cm)
    set align(horizon)
    grid(
      columns: (1fr, 3fr),
      inset: 10pt,
      align: (right,left),
      fill: (dark-blue, white),
      [#block(height: 100%)],[
        #text(1.2em, weight: "bold", fill: dark-blue)[#it]
        #context {
          let current-page = counter(page).get().first() - 1
          let last-page = counter(page).final().first() - 1
          v(.5em)
          place(right, dx: -20%, line(start: (0cm, 0cm), end: (80% - (current-page * 80% / last-page), 0cm), stroke: 2pt + pink.lighten(50%)))
          place(line(start: (0cm, 0cm), end: (current-page * 80% / last-page, 0cm), stroke: 2pt + pink))
        }
      ]
    )
  }
  show heading.where(level: 2): pagebreak(weak: true) // this is where the magic happens
  show heading: set text(..heading-style, size: 1.1em, fill: dark-blue)

  // ADD. STYLING --------------------------------------------------
  // Terms
  show terms.item: it => {
    set block(width: 100%, inset: 5pt, breakable: false)
    stack(
      block(fill: header-color, radius: (top: 0.2em, bottom: 0cm), strong(it.term)),
      block(fill: block-color, radius: (top: 0cm, bottom: 0.2em), it.description),
    )
  }

  // Code
  show raw.where(block: false): it => {
    box(fill: block-color, inset: 1pt, radius: 1pt, baseline: 1pt)[#text(font: "Cascadia Code", size: 1.25em, it)]
  }

  // Bullet List
  show list: set list(marker: (
    text(fill: dark-blue)[•],
    text(fill: dark-blue)[‣],
    text(fill: dark-blue)[-],
  ))

  // Enum
  let color_number(nrs) = text(fill: dark-blue)[*#nrs.*]
  set enum(numbering: color_number)
  show math.equation: set text(font: "Concrete Math", size: 1.1em)

  // Table
  show table: set table(
    stroke: (x, y) => (
      x: none,
      bottom: 0.8pt + black,
      top: if y == 0 {0.8pt + black} else if y==1 {0.4pt + black} else { 0pt },
    )
  )
  
  show table.cell.where(y: 0): set text(
    style: "normal", weight: "bold") // for first / header row

  set table.hline(stroke: 0.4pt+black)
  set table.vline(stroke: 0.4pt)

  // Quote
  set quote(block: true)
  show quote.where(block: true): it => {
    v(-5pt)
    block(
      fill: block-color, inset: 5pt, radius: 1pt, 
      stroke: (left: 3pt + fill-color), width: 100%, 
      outset: (left:-5pt, right:-5pt, top: 5pt, bottom: 5pt)
      )[#it]
    v(-5pt)
  }

  // Link
  show link: it => {
    // Cross-reference
    if type(it.dest) != str { it }
    else {
      underline(stroke: 0.5pt + pink, text(fill: pink, it)) // Web Links
    } 
  }

  // Outline
  set outline(
    // target: heading.where(level: 1),
    indent: .5cm,
  )

  // To not make the TOC heading a section slide by itself
  show outline: set heading(level: 2) 

  // Bibliography
  set bibliography(
    title: none
  )
  
  // CONTENT---------------------------------------------
  // Title Slide
  if (title == none) { panic("A title is required") }
  else {
    set page(footer: none, header: none, margin: 0cm)
    block(
      inset: (x:0.5cm, y:1em),
      fill: dark-blue,
      width: 100%,
      height: 50%,
      align(bottom)[#text(3em, weight: "semibold", font: "Chakra Petch", fill: white, title)]
    )
    block(
      height: 30%,
      width: 100%,
      inset: (x:0.5cm,top:0cm, bottom: 1em))[
      #if subtitle != none [
        #text(1.4em, fill: dark-blue, weight: "bold", subtitle)
      ]
      
      #if authors != none { 
        set text(size: 1.3em)
        authors.map(it => [#it.name #super(it.affiliation)]).join(separator)
        [\ ]
      }
      #if date != none { 
        let date-object = parse-date(date)
        if type(date-object) == datetime {
          date-object.display()
        } else {
          date-object
        }
        [\ \ ]
      }
      #if affiliations != none {
        set text(fill: black.lighten(40%))
        affiliations.enumerate().map(it => [#super([#{it.at(0) + 1}])#it.at(1)]).join([ \ ])
      }
    ]
  }
  

  // Outline
  if (toc == true) {
    outline(depth: toc_depth, title: toc_title)
  }

  set par(leading: 1em)

  // Normal Content
  doc
  
}

#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = block(breakable: false,
  table(
    stroke: none,
    columns: (auto, 1fr),
    align: horizon,
    fill: (x, y) => if x == 0 { icon_color } else { none },
    inset: 0em,
    block(width: .2em),
    block(
      width: 100%,
      inset: (x: 1em, y: .75em),
    )[
      #set text(weight: "regular")
      #set par(leading: .75em)
      #text(fill: icon_color, [#icon #h(.25em) #strong(title)])\ #v(-.25em)
      #body
      #v(.15em)
    ]
  )
)

#let horizontalrule = [
  #pagebreak()
]