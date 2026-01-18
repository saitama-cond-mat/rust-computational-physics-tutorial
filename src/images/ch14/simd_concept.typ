#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas({
  import cetz.draw: *
  
  let box_w = 0.8
  
  // Scalar
  content((-1, 2))["Scalar"]
  rect((0, 1.6), (box_w, 2.4), fill: blue.lighten(90%))
  content((box_w/2, 2))[$a_0$]
  content((box_w + 0.4, 2))[$+$]
  rect((box_w + 0.8, 1.6), (box_w*2 + 0.8, 2.4), fill: red.lighten(90%))
  content((box_w*1.5 + 0.8, 2))[$b_0$]
  line((box_w*2 + 1.2, 2), (box_w*2 + 1.8, 2), mark: (end: ">"))
  rect((box_w*2 + 2, 1.6), (box_w*3 + 2, 2.4), fill: green.lighten(90%))
  content((box_w*2.5 + 2, 2))[$c_0$]
  
  // SIMD
  content((-1, -1))["SIMD"]
  for i in range(0, 4) {
    let y = -i * 0.9
    rect((0, y), (box_w, y + 0.8), fill: blue.lighten(90%))
    content((box_w/2, y + 0.4))[$a_#i$]
    
    content((box_w + 0.4, y + 0.4))[$+$]
    
    rect((box_w + 0.8, y), (box_w*2 + 0.8, y + 0.8), fill: red.lighten(90%))
    content((box_w*1.5 + 0.8, y + 0.4))[$b_#i$]
    
    line((box_w*2 + 1.2, y + 0.4), (box_w*2 + 1.8, y + 0.4), mark: (end: ">"))
    
    rect((box_w*2 + 2, y), (box_w*3 + 2, y + 0.8), fill: green.lighten(90%))
    content((box_w*2.5 + 2, y + 0.4))[$c_#i$]
  }
  
  // Bracket for SIMD
  line((-0.2, 0.8), (-0.4, 0.8), (-0.4, -3.5), (-0.2, -3.5))
  content((-1.5, -1.35))[Single \ Instruction]
})
