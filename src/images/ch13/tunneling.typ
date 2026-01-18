#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas({
  import cetz.draw: *
  
  // Potential Barrier
  let bx = 0
  let bw = 0.5
  let bh = 2.5
  rect((bx - bw, 0), (bx + bw, bh), fill: gray.lighten(80%), stroke: 1pt)
  content((bx, bh + 0.3))[$V_0$]

  // Wavepacket (Incoming)
  let gaussian(x, x0, s) = calc.exp(-calc.pow(x - x0, 2) / (2 * calc.pow(s, 2)))
  let wave(x, x0, s, k) = gaussian(x, x0, s) * calc.sin(k * x * 10)
  
  // Left side (Incoming + Reflected)
  let pts_left = ()
  for i in range(-400, -50) {
    let x = i / 100
    let y = 1.0 + wave(x, -2, 0.5, 2)
    pts_left.push((x, y))
  }
  line(..pts_left, stroke: blue + 1.5pt)
  line((-2.5, 2.2), (-1.5, 2.2), mark: (end: ">"), stroke: 2pt)
  content((-2, 2.5))["Incoming Wave"]

  // Right side (Transmitted)
  let pts_right = ()
  for i in range(50, 400) {
    let x = i / 100
    let y = 1.0 + 0.4 * wave(x, 2, 0.5, 2) // Lower amplitude
    pts_right.push((x, y))
  }
  line(..pts_right, stroke: blue + 1pt)
  line((1.5, 1.6), (2.5, 1.6), mark: (end: ">"), stroke: 1pt)
  content((2, 1.9))["Transmitted Wave"]

  // Axes
  line((-4, 0), (4, 0), mark: (end: ">"))
  content((4, -0.3))[$x$]
  line((0, 0), (0, 3.5), stroke: gray + 0.5pt)
})
