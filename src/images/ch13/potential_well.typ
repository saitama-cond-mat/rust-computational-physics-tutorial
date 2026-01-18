#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas({
  import cetz.draw: *
  
  // Potential Well
  line((-3, 3), (-1, 3), ( -1, 0), (1, 0), (1, 3), (3, 3), stroke: 2pt)
  content((0, -0.4))[$V = 0$]
  content((-2, 3.4))[$V = V_0$]
  
  // Wavefunction (Ground state)
  let f(x) = 1.2 * calc.cos(x * 1.3) + 0.5
  let pts = ()
  for i in range(-120, 121) {
    let x = i / 100
    if x < -1 {
      pts.push((x, 0.5 + 1.2 * calc.cos(1.3) * calc.exp(2 * (x + 1))))
    } else if x > 1 {
      pts.push((x, 0.5 + 1.2 * calc.cos(1.3) * calc.exp(-2 * (x - 1))))
    } else {
      pts.push((x, f(x)))
    }
  }
  line(..pts, stroke: blue + 1.5pt)
  content((0, 1.8), [$psi_0(x)$], fill: blue)
  
  // Energy Level
  line((-1, 0.5), (1, 0.5), stroke: (paint: red, dash: "dashed"))
  content((1.5, 0.5))[$E_0$]
  
  // Axes
  line((-3.5, 0), (3.5, 0), mark: (end: ">"))
  content((3.5, -0.3))[$x$]
})
