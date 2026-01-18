#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas({
  import cetz.draw: *
  
  let size = 2
  
  // Grid lines
  grid((0, 0), (size*2, size*2), step: 2, stroke: gray + 0.5pt)
  
  // Cells
  for i in range(0, size) {
    for j in range(0, size) {
      let x = i * 2
      let y = j * 2
      let cx = x + 1
      let cy = y + 1
      
      // Pressure (Center)
      circle((cx, cy), radius: 0.1, fill: black)
      content((cx, cy + 0.3))[$p_(i, j)$]
      
      // u-velocity (Right/Left face)
      if i < size {
        line((x + 2, cy - 0.2), (x + 2, cy + 0.2), stroke: (thickness: 2pt, cap: "round"), mark: (end: ">"))
        content((x + 2.4, cy + 0.3))[$u_(i, j)$]
      }
      
      // v-velocity (Top/Bottom face)
      if j < size {
        line((cx, y + 2), (cx, y + 2.4), stroke: (thickness: 2pt, cap: "round"), mark: (end: ">"))
        content((cx + 0.5, y + 2.2))[$v_(i, j)$]
      }
    }
  }
  
  // Legend
  content((size + 1, -1))[
    $dot$ : Pressure $p$ \ 
    $arrow.r$ : Velocity $u$ \ 
    $arrow.t$ : Velocity $v$
  ]
})