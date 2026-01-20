#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *
  
  let s = 2.0

  // Axes
  line((0, 0), (6 * s, 0), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  content((6 * s, -0.3 * s))[$"Temperature" (T)$]
  line((0, 0), (0, 4 * s), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  // Adjusted Y-axis label position
  content((0.2 * s, 4 * s), anchor: "south-west")[$"Magnetization" (m)$]
  
  // Critical Temperature Tc
  let Tc = 3
  line((Tc * s, 0), (Tc * s, 4 * s), stroke: (paint: gray, dash: "dashed", thickness: 1.5pt))
  content((Tc * s, -0.4 * s))[$T_c$]
  
  // Curve
  let pts = ()
  for i in range(0, 300) {
    let t = i / 100
    if t < Tc {
      let m = 3.5 * calc.pow(1 - t/Tc, 1/8) // 2D Ising beta = 1/8
      pts.push((t * s, m * s))
    } else {
      pts.push((t * s, 0))
    }
  }
  line(..pts, stroke: (paint: blue, thickness: 3pt))
  
  // Phase labels
  content((1.5 * s, 1 * s))["Ferromagnetic" \ ($m eq.not 0$)]
  content((4.5 * s, 1 * s))["Paramagnetic" \ ($m approx 0$)]
})
