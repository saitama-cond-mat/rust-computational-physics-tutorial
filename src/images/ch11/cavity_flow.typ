#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *

  let s = 2.0
  let L = 4

  // Box (0,0) to (8,8)
  rect((0, 0), (L * s, L * s), stroke: 3pt)

  // Moving Lid (Top)
  line((0, L * s), (L * s, L * s), stroke: (paint: red, thickness: 4pt), mark: (end: ">", size: 0.6))
  content((L * s / 2, L * s + 0.2 * s))[$U = 1.0$ (Moving Wall)]

  // Stationary Walls
  content((-1 * s, L * s / 2))[Stationary Wall]
  content((L * s + 1 * s, L * s / 2))[Stationary Wall]
  content((L * s / 2, -0.2 * s))[Stationary Wall]

  // Flow schematic (Primary Vortex)
  let v_center_x = L * s / 2
  let v_center_y = L * s * 0.65 // Shifted higher
  let r = 1.2 * s // Smaller radius to stay clear of walls

  // Start point calculation
  let start_angle = 45deg
  let start_pos = (
    v_center_x + r * calc.cos(start_angle),
    v_center_y + r * calc.sin(start_angle)
  )

  arc(
    start_pos,
    radius: r,
    start: start_angle,
    stop: -235deg,
    stroke: (paint: blue, thickness: 3pt),
    mark: (end: ">", size: 0.8)
  )

  content((v_center_x, v_center_y), padding: 0.2)[Primary Vortex]
})
