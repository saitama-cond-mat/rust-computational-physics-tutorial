#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 16pt)

#cetz.canvas({
    import cetz.draw: *

    let n = 6
    let s = 1.5 // Increased grid size
    
    // Draw grid
    for i in range(n) {
        for j in range(n) {
            rect((j*s, -i*s), ((j+1)*s, -(i+1)*s), stroke: gray + 1.5pt, fill: white)
        }
    }

    // Fill diagonal (tridiagonal)
    for i in range(n) {
        // Main Diagonal
        rect((i*s, -i*s), ((i+1)*s, -(i+1)*s), fill: rgb("#3b82f6"), stroke: gray + 1.5pt)
        
        // Upper diagonal
        if i < n - 1 {
            rect(((i + 1)*s, -i*s), ((i + 2)*s, -(i + 1)*s), fill: rgb("#93c5fd"), stroke: gray + 1.5pt)
        }
        
        // Lower diagonal
        if i > 0 {
             rect(((i - 1)*s, -i*s), (i*s, -(i + 1)*s), fill: rgb("#93c5fd"), stroke: gray + 1.5pt)
        }
    }
    
    // Annotations
    // Main diagonal
    line((-0.5, -0.5 * s), (-0.2, -0.5 * s), mark: (start: ">", size: 0.5), stroke: 1.5pt)
    content((-0.6, -0.5 * s), anchor: "east")[Main Diagonal (-2.0)]
    
    // Off diagonal
    line((n*s + 0.5, -0.5 * s), (n*s - 0.8, -0.5 * s), mark: (start: ">", size: 0.5), stroke: 1.5pt)
    content((n*s + 0.6, -0.5 * s), anchor: "west")[Off Diagonal (1.0)]

})
