#import "@preview/cetz:0.4.2"

#set page(width: auto, height: auto, margin: .5cm)

#cetz.canvas({
    import cetz.draw: *

    let n = 6
    let s = 1.0
    
    // Draw grid
    for i in range(n) {
        for j in range(n) {
            rect((j*s, -i*s), ((j+1)*s, -(i+1)*s), stroke: gray + 0.5pt, fill: white)
        }
    }

    // Fill diagonal (tridiagonal)
    for i in range(n) {
        // Main Diagonal
        rect((i*s, -i*s), ((i+1)*s, -(i+1)*s), fill: rgb("#3b82f6"))
        
        // Upper diagonal
        if i < n - 1 {
            rect(((i + 1)*s, -i*s), ((i + 2)*s, -(i + 1)*s), fill: rgb("#93c5fd"))
        }
        
        // Lower diagonal
        if i > 0 {
             rect(((i - 1)*s, -i*s), (i*s, -(i + 1)*s), fill: rgb("#93c5fd"))
        }
    }
    
    // Annotations
    // Main diagonal
    line((-0.5, -0.5), (-0.2, -0.5), mark: (start: ">"))
    content((-0.6, -0.5), anchor: "east")[Main Diagonal (-2.0)]
    
    // Off diagonal
    line((n*s + 0.5, -0.5), (n*s - 0.8, -0.5), mark: (start: ">"))
    content((n*s + 0.6, -0.5), anchor: "west")[Off Diagonal (1.0)]

    // Matrix brackets (visual style)
    // line((-0.1, 0.1), (-0.1, -n*s - 0.1), stroke: 2pt)
    // line((-0.1, 0.1), (0.2, 0.1), stroke: 2pt)
    // line((-0.1, -n*s - 0.1), (0.2, -n*s - 0.1), stroke: 2pt)
    
    // line((n*s + 0.1, 0.1), (n*s + 0.1, -n*s - 0.1), stroke: 2pt)
    // line((n*s + 0.1, 0.1), (n*s - 0.2, 0.1), stroke: 2pt)
    // line((n*s + 0.1, -n*s - 0.1), (n*s - 0.2, -n*s - 0.1), stroke: 2pt)
})
