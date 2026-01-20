#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *
  
  let s = 2.0

  // Axes
  line((-4 * s, 0), (4 * s, 0), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  content((4 * s, -0.3 * s))[$q$]
  line((0, -4 * s), (0, 4 * s), mark: (end: ">", size: 0.5), stroke: 1.5pt)
  content((-0.3 * s, 4 * s))[$p$]
  
  // Origin label
  content((-0.3 * s, -0.3 * s))[$O$]
  
  // Ideal orbit (Circle)
  circle((0, 0), radius: 2.5 * s, stroke: (paint: gray, dash: "dashed", thickness: 2pt))
  
  // Euler method
  let euler_pts = ()
  for i in range(0, 100) {
    let angle = i * 0.1
    let r = 2.5 + i * 0.015
    euler_pts.push((r * calc.cos(angle) * s, r * calc.sin(angle) * s))
  }
  line(..euler_pts, stroke: red + 3pt)
  
  // Symplectic method
  let symp_pts = ()
  for i in range(0, 63) {
    let angle = i * 0.1
    let r = 2.5 + 0.1 * calc.sin(angle * 8)
    symp_pts.push((r * calc.cos(angle) * s, r * calc.sin(angle) * s))
  }
  line(..symp_pts, stroke: blue + 3pt, close: true)
  
  // -- Labels with Arrows --
  
  // 1. Ideal
  // Top-Right quadrant
  let ideal_label_pos = (3 * s, 3 * s)
  let ideal_target = (2.5 * s * 0.707, 2.5 * s * 0.707) 
  line(ideal_label_pos, ideal_target, mark: (end: ">", size: 0.5), stroke: gray + 1.5pt)
  content(ideal_label_pos, anchor: "south-west", padding: 0.2)[Ideal \ (Energy Constant)]

  // 2. Euler
  // Top-Left quadrant
  let euler_label_pos = (-3 * s, 3 * s)
  let e_angle = 2.3
  let e_r = 2.5 + 23 * 0.015
  let euler_target = (e_r * calc.cos(e_angle) * s, e_r * calc.sin(e_angle) * s)
  
  line(euler_label_pos, euler_target, mark: (end: ">", size: 0.5), stroke: red + 1.5pt)
  content(euler_label_pos, anchor: "south-east", padding: 0.2, fill: red)[Euler \ (Energy Drift)]

  // 3. Symplectic
  // Bottom-Right quadrant
  let symp_label_pos = (2.5 * s, -2.5 * s)
  let s_angle = 5.5
  let s_r = 2.5 + 0.1 * calc.sin(s_angle * 8)
  let symp_target = (s_r * calc.cos(s_angle) * s, s_r * calc.sin(s_angle) * s)
  
  line(symp_label_pos, symp_target, mark: (end: ">", size: 0.5), stroke: blue + 1.5pt)
  content(symp_label_pos, anchor: "north-west", padding: 0.2, fill: blue)[Symplectic \ (Oscillating)]
})