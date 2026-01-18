#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 0.5cm)

#cetz.canvas({
  import cetz.draw: *
  
  let w = 4
  let h = 0.8
  
  // Data array
  rect((0, 0), (w*3, h), stroke: 1pt, fill: gray.lighten(90%))
  for i in range(1, 3) { line((w*i, 0), (w*i, h)) }
  content((w*1.5, h*0.5))[Data Array]
  
  // Split
  line((w*0.5, -0.2), (w*0.5, -1), mark: (end: ">"))
  line((w*1.5, -0.2), (w*1.5, -1), mark: (end: ">"))
  line((w*2.5, -0.2), (w*2.5, -1), mark: (end: ">"))
  
  // Threads
  for i in range(0, 3) {
    let x = w * i
    rect((x + 0.2, -2), (x + w - 0.2, -1.2), fill: blue.lighten(80%), stroke: (paint: blue, thickness: 1.5pt))
    content((x + w/2, -1.6))["Thread " + str(i+1)]
  }
  
  // Process
  for i in range(0, 3) {
    let x = w * i
    line((x + w/2, -2.1), (x + w/2, -2.8), mark: (end: ">"))
  }
  
  // Result
  rect((0, -3.8), (w*3, -3), stroke: 1pt, fill: green.lighten(90%))
  for i in range(1, 3) { line((w*i, -3.8), (w*i, -3)) }
  content((w*1.5, -3.4))[Result Array]
})
