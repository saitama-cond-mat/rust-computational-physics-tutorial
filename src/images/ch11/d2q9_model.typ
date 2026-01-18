#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas({
  import cetz.draw: *
  
  // Center
  circle((0, 0), radius: 0.1, fill: black)
  content((0.3, -0.3))[$e_0$]
  
  let r = 2
  
  // Directions
  let dirs = (
    (1, 0, "e_1"), (0, 1, "e_2"), (-1, 0, "e_3"), (0, -1, "e_4"),
    (1, 1, "e_5"), (-1, 1, "e_6"), (-1, -1, "e_7"), (1, -1, "e_8")
  )
  
  for (dx, dy, label) in dirs {
    line((0, 0), (dx * r, dy * r), mark: (end: ">", size: 0.3), stroke: 1.5pt)
    // Grid point
    circle((dx * r, dy * r), radius: 0.05, fill: gray)
    // Label
    let lx = dx * r * 1.2
    let ly = dy * r * 1.2
    content((lx, ly))[$#label$]
  }
  
  // Grid lines background
  rect((-r, -r), (r, r), stroke: (paint: gray, dash: "dotted"))
})
