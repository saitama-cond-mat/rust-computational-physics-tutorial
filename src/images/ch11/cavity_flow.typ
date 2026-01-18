#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas({
  import cetz.draw: *
  
  let L = 4
  
  // Box
  rect((0, 0), (L, L), stroke: 2pt)
  
  // Moving Lid
  line((0, L), (L, L), stroke: (paint: red, thickness: 3pt), mark: (end: ">"))
  content((L/2, L + 0.5))[$U = 1.0$ (Moving Wall)]
  
  // Stationary Walls
  content((-0.8, L/2))[Stationary Wall]
  content((L + 0.8, L/2))[Stationary Wall]
  content((L/2, -0.5))[Stationary Wall]
  
  // Flow schematic (Primary Vortex)
  bezier(
    (L/2 + 0.5, L - 0.5), (L - 0.5, L - 0.5), (L - 0.5, 0.5), (L/2, 0.5),
    stroke: (paint: blue, dash: "dashed"), mark: (end: ">")
  )
  bezier(
    (L/2, 0.5), (0.5, 0.5), (0.5, L - 0.5), (L/2 - 0.5, L - 0.5),
    stroke: (paint: blue, dash: "dashed"), mark: (end: ">")
  )
  content((L/2, L/2))[Primary Vortex]
})
