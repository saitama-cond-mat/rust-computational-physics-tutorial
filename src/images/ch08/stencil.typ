#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 1cm)

#cetz.canvas({
    import cetz.draw: *
    
    let dx = 1.5
    let dy = 1.5
    
    // Grid lines
    for i in range(-1, 2) {
        line((i*dx, -1.5*dy), (i*dx, 1.5*dy), stroke: gray.lighten(50%))
        line((-1.5*dx, i*dy), (1.5*dx, i*dy), stroke: gray.lighten(50%))
    }
    
    // Center point (i, j)
    circle((0, 0), radius: 0.1, fill: red)
    content((0.2, 0.2))[$u_(i,j)$]
    
    // Neighbors
    circle((dx, 0), radius: 0.1, fill: blue)
    content((dx+0.2, 0.2))[$u_(i+1,j)$]
    
    circle((-dx, 0), radius: 0.1, fill: blue)
    content((-dx+0.2, 0.2))[$u_(i-1,j)$]
    
    circle((0, dy), radius: 0.1, fill: blue)
    content((0.2, dy+0.2))[$u_(i,j+1)$]
    
    circle((0, -dy), radius: 0.1, fill: blue)
    content((0.2, -dy+0.2))[$u_(i,j-1)$]
    
    // Stencil connections
    line((0,0), (dx, 0), stroke: (paint: black, thickness: 1.5pt))
    line((0,0), (-dx, 0), stroke: (paint: black, thickness: 1.5pt))
    line((0,0), (0, dy), stroke: (paint: black, thickness: 1.5pt))
    line((0,0), (0, -dy), stroke: (paint: black, thickness: 1.5pt))
    
    content((0, -2.5))[5-point Stencil (Laplacian)]
})
