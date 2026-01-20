#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
  import cetz.draw: *
  
  let s = 2.0
  let w = 4 * s
  let h = 0.8 * s
  
  // Data array
  rect((0, 0), (w*3, h), stroke: 2pt, fill: gray.lighten(90%))
  for i in range(1, 3) { line((w*i, 0), (w*i, h), stroke: 1.5pt) }
  content((w*1.5, h*0.5))[Data Array]
  
  // Split
  line((w*0.5, -0.2 * s), (w*0.5, -1 * s), mark: (end: ">", size: 0.6), stroke: 2pt)
  line((w*1.5, -0.2 * s), (w*1.5, -1 * s), mark: (end: ">", size: 0.6), stroke: 2pt)
  line((w*2.5, -0.2 * s), (w*2.5, -1 * s), mark: (end: ">", size: 0.6), stroke: 2pt)
  
  // Threads
  for i in range(0, 3) {
    let x = w * i
    rect((x + 0.2 * s, -2 * s), (x + w - 0.2 * s, -1.2 * s), fill: blue.lighten(80%), stroke: (paint: blue, thickness: 2.5pt))
    content((x + w/2, -1.6 * s))["Thread " + str(i+1)]
  }
  
  // Process
  for i in range(0, 3) {
    let x = w * i
    line((x + w/2, -2.1 * s), (x + w/2, -2.8 * s), mark: (end: ">", size: 0.6), stroke: 2pt)
  }
  
  // Result
  rect((0, -3.8 * s), (w*3, -3 * s), stroke: 2pt, fill: green.lighten(90%))
  for i in range(1, 3) { line((w*i, -3.8 * s), (w*i, -3 * s), stroke: 1.5pt) }
  content((w*1.5, -3.4 * s))[Result Array]
})
