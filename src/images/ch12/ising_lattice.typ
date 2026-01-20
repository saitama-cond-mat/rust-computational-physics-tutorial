#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *
  
  let s = 2.0
  let size = 4
  let spacing = 1.5 * s
  
  // Grid lines
  for i in range(0, size) {
    line((i * spacing, 0), (i * spacing, (size - 1) * spacing), stroke: gray + 1.5pt)
    line((0, i * spacing), ((size - 1) * spacing, i * spacing), stroke: gray + 1.5pt)
  }
  
  // Spins
  let spins = (
    (1, -1, 1, 1),
    (1, 1, -1, 1),
    (-1, 1, 1, -1),
    (1, -1, -1, 1)
  )
  
  for y in range(0, size) {
    for x in range(0, size) {
      let px = x * spacing
      let py = y * spacing
      let spin = spins.at(y).at(x)
      
      // Lattice point
      circle((px, py), radius: 0.25 * s, fill: if spin > 0 { red } else { blue }, stroke: none)
      
      // Arrow with white outline
      let p_start = if spin > 0 { (px, py - 0.45 * s) } else { (px, py + 0.45 * s) }
      let p_end = if spin > 0 { (px, py + 0.45 * s) } else { (px, py - 0.45 * s) }
      
      // 1. Draw thicker white arrow as outline (slightly larger mark to be visible)
      line(p_start, p_end, 
           stroke: (thickness: 6.5pt, paint: white), 
           mark: (end: ">", size: 0.85, fill: white))
      
      // 2. Draw the colored arrow on top
      line(p_start, p_end, 
           stroke: (thickness: 3pt, paint: if spin > 0 { red.darken(25%) } else { blue.darken(25%) }), 
           mark: (end: ">", size: 0.6, fill: if spin > 0 { red.darken(25%) } else { blue.darken(25%) }))
    }
  }
  
  // Legend
  let lx = spacing * size + 0.5 * s
  let ly = spacing * size / 2
  
  content((lx + 1.5 * s, ly))[
    #set text(size: 14pt)
    #box(fill: white, inset: 8pt, stroke: gray + 1pt)[
      #std.grid(columns: 2, gutter: 12pt, align: horizon,
        [#text(fill: red.darken(25%), size: 20pt)[$arrow.t$]], [Spin +1 (Up)],
        [#text(fill: blue.darken(25%), size: 20pt)[$arrow.b$]], [Spin -1 (Down)]
      )
    ]
  ]
})
