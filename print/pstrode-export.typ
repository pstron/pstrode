/* Base template of pstrode-export
 *
 * Derived from oi-wiki-export-typst/oi-wiki-export.typ of OI-Wiki-export.
 * Keep the structure in sync when bumping the upstream input, and only keep
 * pstrode specific changes here:
 *   - front/back cover
 *   - two-column table of contents
 *   - correct page numbers for internal references
 */

/* BEGIN imports */
#import "constants.typ": *
#import "oi-wiki.typ": page-header
/* END imports */
#show ref: it => {
  if query(it.target).len() == 0 {
    return text(fill: red, "<未找到引用" + str(it.target) + ">")
  }
  it
}

/* BEGIN meta */
#set text(
  lang: "zh",
  region: "cn",
)
/* END meta */

/* BEGIN front cover */
#set page(
  header: none,
  paper: "a4",
  header-ascent: .3in,
  fill: luma(95%),
)

#align(center + horizon)[
  // pstron logo
  #image("pstron.svg", height: 4cm)
  #text(
    25pt,
    font: serif-font,
    weight: 700,
  )[pstrode]
  #v(4cm)
  #text(
    18pt,
    font: serif-font,
  )[
    pstron

    #(
      datetime
        .today()
        .display("[year] 年 [month padding:none] 月 [day padding:none] 日")
    )
  ]
]

#pagebreak(to: "odd", weak: true)
/* END front cover */

/* BEGIN article formatting */

#set page(
  fill: none,
  // header: text(9pt)[
  //   #counter(page).display("i")
  //   #h(1fr)
  // ]
)
#counter(page).update(1)

#set text(
  ROOT_EM,
  font: serif-font,
)

#set par(
  leading: .8em,
  // HACK: CJK-style first line indent is still in progress
  // we are currently using JS build tools to solve this
  // issues: https://github.com/typst/typst/issues/311
  //         https://github.com/typst/typst/issues/1410
  // first-line-indent: 2em,
  linebreaks: "optimized",
  justify: true,
)
#show raw.where(block: true): set par(justify: false)

#set block(spacing: .8em)

#set strong(delta: 0)
#show strong: set text(
  font: sans-font,
  // New Computer Modern: 400      |----->700
  // Noto Sans CJK:       400 500<-|      700
  // DejaVu Sans Mono:    400      |----->700
  // font-that-has-600:   400 500  |->600 700
  //                              551
  weight: 551,
)

#set heading(numbering: "1.1")
#show heading: set text(
  font: sans-font,
  weight: 551,
)
#show heading.where(level: 1): set text(18pt)
#show heading.where(level: 2): it => {
  set text(16pt)
  v(1em, weak: true)
  align(center, it)
  v(1em, weak: true)
}
#show heading.where(level: 3): it => {
  set text(14pt)
  v(1em, weak: true)
  it
  v(1em, weak: true)
}
#show heading.where(level: 4): set text(12pt)
#show heading.where(level: 5): set text(11pt)
#show heading.where(level: 6): set text(10pt)

#show emph: set text(font: emph-font)

#show math.equation: set text(font: math-font)

#show raw: set text(
  RAW_EM,
  font: raw-font,
)

#show raw.where(block: false): it => highlight(
  fill: luma(95%),
  it,
)
/* END article formatting */

/* BEGIN outline */
// A single outline cannot be split across columns, so the entries are
// collected manually and laid out in two balanced columns.
//
// Every entry gets an explicit row height: Typst measures a single line of
// text very tightly (the body uses `leading: .8em`), which would make the
// entries overlap otherwise.
#let toc-column(entries) = grid(
  columns: (auto, 1fr, auto),
  column-gutter: 0.4em,
  row-gutter: 0.35em,
  rows: entries.map(entry => if entry.level == 1 { 2.4em } else { 1.6em }),
  align: (left + horizon, left + horizon, right + horizon),
  ..entries
    .map(entry => (
      box(width: (entry.level - 1) * 1.2em)
        + {
          if entry.number != none {
            text(font: sans-font, size: 9pt, entry.number)
            h(0.5em)
          }
        }
        + if entry.level == 1 {
          text(size: 12pt, font: sans-font, weight: 551, entry.title)
        } else {
          entry.title
        },
      repeat(text(fill: luma(55%), size: 9pt)[.]),
      text(size: 9pt, number-width: "tabular")[#entry.page],
    ))
    .flatten(),
)

#let toc(entries) = {
  // Weight level 1 entries a bit more, then split at the chapter boundary
  // that is closest to the middle of the table of contents.
  let weight(entry) = if entry.level == 1 { 3 } else { 1 }
  let total = entries.fold(0, (acc, entry) => acc + weight(entry))
  let target = total / 2
  let best = 0
  let best-diff = 1e9
  let acc = 0
  for (index, entry) in entries.enumerate() {
    if index > 0 and entry.level == 1 {
      let diff = calc.abs(acc - target)
      if diff < best-diff {
        best-diff = diff
        best = index
      }
    }
    acc += weight(entry)
  }
  if best == 0 {
    best = calc.ceil(entries.len() / 2)
  }

  grid(
    columns: (1fr, 1fr),
    column-gutter: 1.8em,
    align: top,
    toc-column(entries.slice(0, best)),
    toc-column(entries.slice(best)),
  )
}

#heading(level: 1, numbering: none, outlined: false)[目录]

#context {
  let entries = query(heading.where(outlined: true)).map(entry => (
    level: entry.level,
    number: if entry.numbering == none {
      none
    } else if entry.level == 1 {
      numbering("1", ..counter(heading).at(entry.location()))
    } else {
      numbering(entry.numbering, ..counter(heading).at(entry.location()))
    },
    title: entry.body,
    // NOTE: the physical page index differs from the printed page number,
    // because the page counter is reset after the front matter.
    page: counter(page).at(entry.location()).first(),
  ))
  toc(entries)
}
/* END outline */

/* BEGIN main */
#set page(header: page-header)

#counter(page).update(1)

#show heading.where(level: 1): it => {
  set text(
    25pt,
    font: serif-font,
    weight: 700,
  )
  set par(first-line-indent: 0em)

  align(horizon)[
    第#counter(heading).display("一")章

    #it.body
  ]
}

#show heading.where(level: 2): it => {
  counter(footnote).update(0)
  it
}

// Metrics in New Computer Modern
// Width of digits:     500 units
//       of period:     278 units
//       of bullet:     778 units
//       of whitespace: 333 units
#set list(
  indent: 2em,
)
#show list: set block(width: 100%)
#set enum(
  indent: 2em,
)
#show enum: set block(width: 100%)

#show ref: it => {
  let el = it.element
  if el != none and el.func() == heading and it.form == "normal" and it.supplement != auto {
    context {
      let loc = el.location()
      // Use the page counter instead of the physical page index so that the
      // reference points at the number printed in the page header.
      let page-number = counter(page).at(loc).first()
      link(
        loc,
        it.supplement + text(size: 0.9em, "→" + numbering(
          el.numbering,
          ..counter(heading).at(loc)
        ) + "@p" + str(page-number))
      )
    }
  } else {
    it
  }
}
#show ref: set text(fill: cmyk(0%, 100%, 100%, 0%))

#show footnote.entry: it => {
  set text(9pt)
  it
}

#include "includes.typ"
/* END main */

/* BEGIN back cover */
#pagebreak(to: "odd")

#set page(
  header: none,
  fill: luma(95%),
)

#align(
  center + horizon,
  text(17pt)[gto.sh/cp],
)
/* END back cover */
