#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *
  
  let s = 2.0
  let box_w = 0.8 * s
  
  // Scalar
  content((-1 * s, 2 * s))["Scalar"]
  rect((0, 1.6 * s), (box_w, 2.4 * s), fill: blue.lighten(90%), stroke: 1.5pt)
  content((box_w/2, 2 * s))[$a_0$]
  content((box_w + 0.4 * s, 2 * s))[$+$]
  rect((box_w + 0.8 * s, 1.6 * s), (box_w*2 + 0.8 * s, 2.4 * s), fill: red.lighten(90%), stroke: 1.5pt)
  content((box_w*1.5 + 0.8 * s, 2 * s))[$b_0$]
  line((box_w*2 + 1.2 * s, 2 * s), (box_w*2 + 1.8 * s, 2 * s), mark: (end: ">", size: 0.6), stroke: 2pt)
  rect((box_w*2 + 2 * s, 1.6 * s), (box_w*3 + 2 * s, 2.4 * s), fill: green.lighten(90%), stroke: 1.5pt)
  content((box_w*2.5 + 2 * s, 2 * s))[$c_0$]
  
  // SIMD
  content((-1 * s, -1 * s))["SIMD"]
  for i in range(0, 4) {
    let y = -i * 0.9 * s
    rect((0, y), (box_w, y + 0.8 * s), fill: blue.lighten(90%), stroke: 1.5pt)
    content((box_w/2, y + 0.4 * s))[$a_#i$]
    
    content((box_w + 0.4 * s, y + 0.4 * s))[$+$]
    
    rect((box_w + 0.8 * s, y), (box_w*2 + 0.8 * s, y + 0.8 * s), fill: red.lighten(90%), stroke: 1.5pt)
    content((box_w*1.5 + 0.8 * s, y + 0.4 * s))[$b_#i$]
    
    line((box_w*2 + 1.2 * s, y + 0.4 * s), (box_w*2 + 1.8 * s, y + 0.4 * s), mark: (end: ">", size: 0.6), stroke: 2pt)
    
    rect((box_w*2 + 2 * s, y), (box_w*3 + 2 * s, y + 0.8 * s), fill: green.lighten(90%), stroke: 1.5pt)
    content((box_w*2.5 + 2 * s, y + 0.4 * s))[$c_#i$]
  }
  
  // Bracket for SIMD
  line((-0.2 * s, 0.8 * s), (-0.4 * s, 0.8 * s), (-0.4 * s, -3.5 * s), (-0.2 * s, -3.5 * s), stroke: 2.5pt)
  content((-1.5 * s, -1.35 * s))[Single \ Instruction]
})
