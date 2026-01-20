#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *

  let s = 2.0

  // Axes
  line((0, 0), (4 * s, 0), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  content((4 * s, -0.3 * s))[$r / sigma$]
  line((0, -2 * s), (0, 3 * s), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  content((-0.2 * s, 3 * s))[$V / epsilon$]

  // Potential Curve
  let f(r) = 4 * (calc.pow(1/r, 12) - calc.pow(1/r, 6))
  let pts = ()
  for i in range(95, 300) {
    let r = i / 100
    pts.push((r * s, f(r) * s))
  }
  line(..pts, stroke: blue + 3pt)

  // Reference lines
  line((0, 0), (4 * s, 0), stroke: (paint: gray, dash: "dashed", thickness: 1.5pt))

  // Minimum point label
  let r_min = calc.pow(2, 1/6)
  circle((r_min * s, -1 * s), radius: 0.15, fill: red)
  content(((r_min + 0.8) * s, -1 * s))[$r_min = 2^(1/6) sigma$]
})
