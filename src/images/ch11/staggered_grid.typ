#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *

  let size = 2
  let s = 3.5

  // Grid lines
  grid((0, 0), (size*s, size*s), step: s, stroke: gray + 2pt)

  // Cells
  for i in range(0, size) {
    for j in range(0, size) {
      let x = i * s
      let y = j * s
      let cx = x + s/2
      let cy = y + s/2

      // Pressure (Center)
      circle((cx, cy), radius: 0.15 * (s/3.5), fill: black)
      content((cx, cy), anchor: "south", padding: 0.3)[$p_(i, j)$]

      // u-velocity (Right face)
      if i < size {
        let arrow_len = 0.3 * (s/3.5)
        line((x + s, cy - arrow_len), (x + s, cy + arrow_len), stroke: (thickness: 4pt, cap: "round", paint: blue), mark: (end: ">", size: 0.8))
        content((x + s, cy), anchor: "west", padding: 0.3)[$u_(i, j)$]
      }

      // v-velocity (Top face)
      if j < size {
        let arrow_len = 0.3 * (s/3.5)
        line((cx - arrow_len, y + s), (cx + arrow_len, y + s), stroke: (thickness: 4pt, cap: "round", paint: red), mark: (end: ">", size: 0.8))
        content((cx, y + s), anchor: "south", padding: 0.3)[$v_(i, j)$]
      }
    }
  }

  // --- Manual Legend for pixel-perfect matching ---
  let lx = 1.0 // Legend start X
  let ly = -0.8 // Legend start Y
  let l_gap = 0.6 // Vertical gap

  // 1. Pressure
  circle((lx, ly), radius: 0.15, fill: black)
  content((lx + 0.4, ly), anchor: "west")[Pressure: $p$]

  // 2. Velocity u
  line((lx - 0.25, ly - l_gap), (lx + 0.25, ly - l_gap), stroke: (thickness: 4pt, cap: "round", paint: blue), mark: (end: ">", size: 0.6))
  content((lx + 0.4, ly - l_gap), anchor: "west")[Velocity: $u$]

  // 3. Velocity v
  // Drawn vertically to match its nature, or horizontally for consistency?
  // Let's draw it vertically but centered in the symbol column.
  line((lx, ly - 2*l_gap - 0.25), (lx, ly - 2*l_gap + 0.25), stroke: (thickness: 4pt, cap: "round", paint: red), mark: (end: ">", size: 0.6))
  content((lx + 0.4, ly - 2*l_gap), anchor: "west")[Velocity: $v$]
})
