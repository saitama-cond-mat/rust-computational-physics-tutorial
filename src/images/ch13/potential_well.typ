#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *

  let s = 2.0

  // Potential Well
  line((-3 * s, 3 * s), (-1 * s, 3 * s), ( -1 * s, 0), (1 * s, 0), (1 * s, 3 * s), (3 * s, 3 * s), stroke: 3pt)
  content((0, -0.2 * s))[$V = 0$]
  content((-2 * s, 3.2 * s))[$V = V_0$]

  // Wavefunction (Ground state)
  let f(x) = 1.2 * calc.cos(x * 1.3) + 0.5
  let pts = ()
  for i in range(-120, 121) {
    let x = i / 100
    if x < -1 {
      pts.push((x * s, (0.5 + 1.2 * calc.cos(1.3) * calc.exp(2 * (x + 1))) * s))
    } else if x > 1 {
      pts.push((x * s, (0.5 + 1.2 * calc.cos(1.3) * calc.exp(-2 * (x - 1))) * s))
    } else {
      pts.push((x * s, f(x) * s))
    }
  }
  line(..pts, stroke: blue + 3pt)
  content((0, 2 * s), [$psi_0(x)$], fill: blue)

  // Energy Level
  line((-1 * s, 0.5 * s), (1 * s, 0.5 * s), stroke: (paint: red, dash: "dashed", thickness: 2pt))
  content((1.3 * s, 0.4 * s))[$E_0$]

  // Axes
  line((-3.5 * s, 0), (3.5 * s, 0), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  content((3.4 * s, -0.2 * s))[$x$]
})
