#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *
    
    let s = 2.5
    let dx = 1.5
    let dy = 1.5
    
    // Grid lines
    for i in range(-1, 2) {
        line((i*dx*s, -1.5*dy*s), (i*dx*s, 1.5*dy*s), stroke: gray.lighten(50%) + 1.5pt)
        line((-1.5*dx*s, i*dy*s), (1.5*dx*s, i*dy*s), stroke: gray.lighten(50%) + 1.5pt)
    }
    
    // Stencil connections
    line((0,0), (dx*s, 0), stroke: (paint: black, thickness: 3pt))
    line((0,0), (-dx*s, 0), stroke: (paint: black, thickness: 3pt))
    line((0,0), (0, dy*s), stroke: (paint: black, thickness: 3pt))
    line((0,0), (0, -dy*s), stroke: (paint: black, thickness: 3pt))
    
    // Center point (i, j)
    circle((0, 0), radius: 0.15 * s, fill: red)
    content((0.15 * s, 0.15 * s), anchor: "south-west")[$u_(i,j)$]
    
    // Neighbors
    circle((dx*s, 0), radius: 0.15 * s, fill: blue)
    content((dx*s + 0.15 * s, 0.15 * s), anchor: "south-west")[$u_(i+1,j)$]
    
    circle((-dx*s, 0), radius: 0.15 * s, fill: blue)
    content((-dx*s - 0.15 * s, 0.15 * s), anchor: "south-east")[$u_(i-1,j)$]
    
    circle((0, dy*s), radius: 0.15 * s, fill: blue)
    content((0.15 * s, dy*s + 0.15 * s), anchor: "south-west")[$u_(i,j+1)$]
    
    circle((0, -dy*s), radius: 0.15 * s, fill: blue)
    content((0.15 * s, -dy*s - 0.15 * s), anchor: "north-west")[$u_(i,j-1)$]
    
    content((0, -2.8 * s))[5-point Stencil (Laplacian)]
})
