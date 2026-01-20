#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *

  let s = 2.0

  // Potential Barrier
  let bx = 0
  let bw = 0.5 * s
  let bh = 2.5 * s
  rect((bx - bw, 0), (bx + bw, bh), fill: gray.lighten(80%), stroke: 2pt)
  content((bx + 0.3, bh + 0.2 * s))[$V_0$]

  // Wavepacket (Incoming)
  let gaussian(x, x0, sigma) = calc.exp(-calc.pow(x - x0, 2) / (2 * calc.pow(sigma, 2)))
  let wave(x, x0, sigma, k) = gaussian(x, x0, sigma) * calc.sin(k * x * 10)

  // Left side (Incoming + Reflected)
  let pts_left = ()
  for i in range(-400, -50) {
    let x = i / 100
    let y = 1.0 + wave(x, -2, 0.5, 2)
    pts_left.push((x * s, y * s))
  }
  line(..pts_left, stroke: blue + 3pt)
  line((-2.5 * s, 2.2 * s), (-1.5 * s, 2.2 * s), mark: (end: ">", size: 0.5), stroke: 2.5pt)
  content((-2 * s, 2.5 * s))["Incoming Wave"]

  // Right side (Transmitted)
  let pts_right = ()
  for i in range(50, 400) {
    let x = i / 100
    let y = 1.0 + 0.4 * wave(x, 2, 0.5, 2) // Lower amplitude
    pts_right.push((x * s, y * s))
  }
  line(..pts_right, stroke: blue + 2pt)
  line((1.5 * s, 1.6 * s), (2.5 * s, 1.6 * s), mark: (end: ">", size: 0.5), stroke: 2pt)
  content((2 * s, 1.9 * s))["Transmitted Wave"]

  // Axes
  line((-4 * s, 0), (4 * s, 0), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  content((3.8 * s, -0.2 * s))[$x$]
  line((0, 0), (0, 3.5 * s), stroke: gray + 1.5pt)
})
