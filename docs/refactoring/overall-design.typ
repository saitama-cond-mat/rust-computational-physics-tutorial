#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 4pt, fill: white)
#set text(font: ("Harano Aji Gothic", "Fira Math"), size: 12pt, lang: "ja", fill: rgb("#0f172a"))

#cetz.canvas({
  import cetz.draw: *

  let unit = 1.14
  let box-w = 4.8 * unit
  let box-h = 1.2 * unit
  let gap-x = 1.0 * unit
  let row-gap = 0.42 * unit
  let source-x = 0.0
  let policy-x = source-x + box-w + gap-x
  let target-x = policy-x + box-w + gap-x
  let target-w = 12.8 * unit
  let top-y = 0.0
  let part-y = -3.85 * unit
  let phase1-y = -5.75 * unit
  let phase2-y = -7.15 * unit
  let footer-y = -8.9 * unit
  let arrow-gap = 0.10 * unit

  let ink = rgb("#0f172a")
  let muted = rgb("#475569")
  let blue = rgb("#2563eb")
  let cyan = rgb("#0891b2")
  let green = rgb("#16a34a")
  let orange = rgb("#ea580c")
  let violet = rgb("#7c3aed")
  let slate = rgb("#64748b")

  let fill-blue = rgb("#dbeafe")
  let fill-cyan = rgb("#cffafe")
  let fill-green = rgb("#e6f4ea")
  let fill-orange = rgb("#ffedd5")
  let fill-violet = rgb("#ede9fe")
  let fill-slate = rgb("#f1f5f9")

  let title = (x, y, w, label) => {
    content((x + w / 2, y))[
      #set text(size: 15pt, weight: "bold")
      #align(center)[#label]
    ]
  }

  let box = (x, y, w, h, fill, stroke-color, body) => {
    rect(
      (x, y),
      (x + w, y - h),
      radius: 0.10 * unit,
      fill: fill,
      stroke: (paint: stroke-color, thickness: 1.4pt),
    )
    content((x + w / 2, y - h / 2))[
      #set text(size: 10.4pt)
      #align(center + horizon)[#body]
    ]
  }

  let small-box = (x, y, w, h, fill, stroke-color, body) => {
    rect(
      (x, y),
      (x + w, y - h),
      radius: 0.08 * unit,
      fill: fill,
      stroke: (paint: stroke-color, thickness: 1.15pt),
    )
    content((x + w / 2, y - h / 2))[
      #set text(size: 9.2pt)
      #align(center + horizon)[#body]
    ]
  }

  let arrow = (from, to, color: ink) => {
    line(from, to, stroke: (paint: color, thickness: 1.45pt), mark: (end: ">", size: 0.55, fill: color))
  }

  title(source-x, top-y + 0.9 * unit, box-w, [Inputs])
  title(policy-x, top-y + 0.9 * unit, box-w, [Integration Policy])
  title(target-x, top-y + 0.9 * unit, target-w, [Refactored Book Structure])

  box(source-x, top-y, box-w, box-h, fill-blue, blue)[
    #strong[Computational Physics in Rust] \
    existing tutorial
  ]
  box(source-x, top-y - box-h - row-gap, box-w, box-h, fill-cyan, cyan)[
    #strong[Agentic Scientific Coding] \
    validation / reproducibility
  ]

  box(policy-x, top-y - 0.64 * unit, box-w, 1.55 * unit, fill-green, green)[
    #strong[Thin Integration] \
    Core: Rust / numerics / physics \
    Agents: plan / check
  ]

  arrow((source-x + box-w + arrow-gap, top-y - box-h / 2), (policy-x - arrow-gap, top-y - 1.05 * unit), color: blue)
  arrow((source-x + box-w + arrow-gap, top-y - box-h - row-gap - box-h / 2), (policy-x - arrow-gap, top-y - 1.05 * unit), color: cyan)

  let part-w = (target-w - 0.75 * unit) / 2
  let part-h = 1.18 * unit
  let p1x = target-x
  let p2x = target-x + part-w + 0.75 * unit

  small-box(p1x, top-y, part-w, part-h, fill-blue, blue)[
    #strong[Part 1: Basics] \
    Rust / setup / plotting
  ]
  small-box(p2x, top-y, part-w, part-h, fill-green, green)[
    #strong[Part 2: Methods] \
    calculus / linear algebra / ODE / MC
  ]
  small-box(p1x, top-y - part-h - row-gap, part-w, part-h, fill-orange, orange)[
    #strong[Part 3: Simulations] \
    mechanics / fluids / Ising / QM
  ]
  small-box(p2x, top-y - part-h - row-gap, part-w, part-h, fill-violet, violet)[
    #strong[Part 4: Advanced] \
    GitHub / profiling / SIMD / parallel
  ]

  arrow((policy-x + box-w + arrow-gap, top-y - 1.05 * unit), (target-x - arrow-gap, top-y - 1.05 * unit), color: green)

  content((target-x + target-w / 2, part-y + 0.45 * unit))[
    #set text(size: 11pt, weight: "bold", fill: muted)
    #align(center)[Cross-cutting practices]
  ]

  let item-w = (target-w - 4 * 0.32 * unit) / 5
  let item-h = 0.95 * unit
  let ix = target-x
  small-box(ix, part-y, item-w, item-h, fill-slate, slate)[Validation]
  small-box(ix + (item-w + 0.32 * unit), part-y, item-w, item-h, fill-slate, slate)[Unit test]
  small-box(ix + 2 * (item-w + 0.32 * unit), part-y, item-w, item-h, fill-slate, slate)[Metadata]
  small-box(ix + 3 * (item-w + 0.32 * unit), part-y, item-w, item-h, fill-slate, slate)[Compute vs plot]
  small-box(ix + 4 * (item-w + 0.32 * unit), part-y, item-w, item-h, fill-slate, slate)[Diff review]

  let lane-x = target-x
  let lane-w = target-w
  box(lane-x, phase1-y, lane-w, 1.05 * unit, rgb("#fff7ed"), orange)[
    #strong[Phase 1: Entrance] \
    README, why-rust, setup, how-to-use, AGENTS, CLAUDE
  ]
  box(lane-x, phase2-y, lane-w, 1.25 * unit, rgb("#f5f3ff"), violet)[
    #strong[Phase 2+] \
    memory layout, unit tests, matrix multiply, Ising, SIMD, GitHub / PR
  ]

  arrow((target-x + target-w / 2, top-y - 2 * part-h - row-gap - arrow-gap), (target-x + target-w / 2, part-y + arrow-gap), color: slate)
  arrow((target-x + target-w / 2, part-y - item-h - arrow-gap), (target-x + target-w / 2, phase1-y + arrow-gap), color: slate)

  content((source-x + (target-x + target-w - source-x) / 2, footer-y))[
    #set text(size: 9.5pt, fill: muted)
    #align(center)[The refactoring should preserve the existing Japanese tutorial style and avoid turning the book into an AI tool manual.]
  ]
})
